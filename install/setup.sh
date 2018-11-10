#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

err() {
  echo "$*" >&2;
}

source ./properties

REQUIRED_APIS="container.googleapis.com monitoring.googleapis.com"
NUM_REQUIRED_APIS=$(wc -w <<< "$REQUIRED_APIS")
NUM_ENABLED_APIS=$(gcloud services list --project $PROJECT_ID \
  --format="value(config.name)" --filter="config.name:($REQUIRED_APIS)" | wc -l)

if [ $NUM_ENABLED_APIS != $NUM_REQUIRED_APIS ]; then
  bold "Enabling required APIs ($REQUIRED_APIS)..."

  gcloud services --project $PROJECT_ID enable $REQUIRED_APIS
fi

SA_EMAIL=$(gcloud iam service-accounts --project $PROJECT_ID list \
  --filter="displayName:$SERVICE_ACCOUNT_NAME" \
  --format='value(email)')

if [ -z "$SA_EMAIL" ]; then
  bold "Creating service account $SERVICE_ACCOUNT_NAME..."

  gcloud iam service-accounts --project $PROJECT_ID create \
    $SERVICE_ACCOUNT_NAME \
    --display-name $SERVICE_ACCOUNT_NAME

  SA_EMAIL=$(gcloud iam service-accounts --project $PROJECT_ID list \
    --filter="displayName:$SERVICE_ACCOUNT_NAME" \
    --format='value(email)')
else
  bold "Using existing service account $SERVICE_ACCOUNT_NAME..."
fi

# TODO: What exact roles are required?
bold "Assigning required roles to $SERVICE_ACCOUNT_NAME..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$SA_EMAIL \
  --role roles/owner \
  --format=none

# TODO: Could verify ACLs here. In the meantime, error messages should suffice.
gsutil ls $BUCKET_URI

if [ $? != 0 ]; then
  bold "Creating bucket $BUCKET_URI..."

  gsutil mb -p $PROJECT_ID $BUCKET_URI
else
  bold "Using existing bucket $BUCKET_URI..."
fi

CLUSTER_EXISTS=$(gcloud beta container clusters list --project $PROJECT_ID \
  --format="value(name)" --filter="name=$GKE_CLUSTER")

if [ -z "$CLUSTER_EXISTS" ]; then
  bold "Creating GKE cluster $GKE_CLUSTER..."

  # TODO: Move some of these config settings to properties file.
  gcloud beta container clusters create $GKE_CLUSTER --project $PROJECT_ID \
    --zone $ZONE --username "admin" --cluster-version "1.11.2" \
    --machine-type "n1-highmem-4" --image-type "COS" --disk-type "pd-standard" \
    --disk-size "100" --service-account $SA_EMAIL --num-nodes "3" \
    --enable-stackdriver-kubernetes --enable-autoupgrade --enable-autorepair \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing
else
  bold "Using existing GKE cluster $GKE_CLUSTER..."
fi

bold "Retrieving credentials for GKE cluster $GKE_CLUSTER..."

gcloud container clusters get-credentials $GKE_CLUSTER --zone $ZONE --project $PROJECT_ID

bold "Provisioning Spinnaker resources..."

kubectl apply -f quick-install.yml

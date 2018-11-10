#!/usr/bin/env bash

source ./properties

gcloud services --project $PROJECT_ID enable container.googleapis.com monitoring.googleapis.com


#SERVICE_ACCOUNT_NAME="spin-acc-$(date +"%s")"
#gcloud iam service-accounts --project $PROJECT_ID create \
#  $SERVICE_ACCOUNT_NAME \
#  --display-name $SERVICE_ACCOUNT_NAME

#SA_EMAIL=$(gcloud iam service-accounts --project $PROJECT_ID list \
#  --filter="displayName:$SERVICE_ACCOUNT_NAME" \
#  --format='value(email)')

# TODO: What exact roles are required?
#gcloud projects add-iam-policy-binding $PROJECT_ID \
#  --member serviceAccount:$SA_EMAIL \
#  --role roles/owner

#gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME



#gcloud beta container --project $PROJECT_ID clusters create $CLUSTER_NAME --zone $ZONE --username "admin" --cluster-version "1.11.2" --machine-type "n1-highmem-4" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --service-account $SA_EMAIL --num-nodes "3" --enable-stackdriver-kubernetes --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair


#gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

#kubectl apply -f quick-install.yml

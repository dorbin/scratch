#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ~/scratch/install/properties

# Query for static ip address as a signal that the Spinnaker installation is exposed via a secured endpoint.
export IP_ADDR=$(gcloud compute addresses list --filter="name=$STATIC_IP_NAME" \
  --format="value(address)" --global --project $PROJECT_ID)

if [ -z "$IP_ADDR" ]; then
  bold "Generating Cloud Shell landing page for unsecured Spinnaker..."
  cat ~/scratch/manage/landing_page_base.md ~/scratch/manage/landing_page_unsecured.md \
    | envsubst > ~/scratch/manage/landing_page_expanded.md
  APP_MANIFEST_MIDDLE=spinnaker_application_manifest_middle_unsecured.yaml
else
  bold "Generating Cloud Shell landing page for secured Spinnaker..."
  cat ~/scratch/manage/landing_page_base.md ~/scratch/manage/landing_page_secured.md \
    | envsubst > ~/scratch/manage/landing_page_expanded.md
  APP_MANIFEST_MIDDLE=spinnaker_application_manifest_middle_secured.yaml
fi

kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
cat ~/scratch/c2d/spinnaker_application_manifest_top.yaml \
  ~/scratch/c2d/$APP_MANIFEST_MIDDLE \
  ~/scratch/c2d/spinnaker_application_manifest_bottom.yaml \
  | envsubst | kubectl apply -f -

bold "Labeling resources as components of application $DEPLOYMENT_NAME..."
kubectl label service --overwrite -n spinnaker spin-clouddriver app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-deck app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-echo app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-front50 app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-gate app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-halyard app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-kayenta app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-orca app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label service --overwrite -n spinnaker spin-rosco app.kubernetes.io/name=$DEPLOYMENT_NAME -o name

kubectl label deployment --overwrite -n spinnaker spin-clouddriver app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-deck app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-echo app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-front50 app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-gate app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label statefulset --overwrite -n spinnaker spin-halyard app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-kayenta app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-orca app.kubernetes.io/name=$DEPLOYMENT_NAME -o name
kubectl label deployment --overwrite -n spinnaker spin-rosco app.kubernetes.io/name=$DEPLOYMENT_NAME -o name

kubectl label pvc --overwrite -n spinnaker halyard-pv-claim app.kubernetes.io/name=$DEPLOYMENT_NAME -o name

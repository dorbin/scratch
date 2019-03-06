#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ~/scratch/install/properties

kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
envsubst < ~/scratch/c2d/spinnaker_application_manifest.yaml | kubectl apply -f -

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

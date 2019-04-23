#!/usr/bin/env bash

if [ -z $CLIENT_ID ]; then
  export CLIENT_ID=$(kubectl get secret -n spinnaker $SECRET_NAME -o json | jq -r .data.client_id | base64 -d)
fi

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

unset BACKEND_SERVICE_ID

printf "Waiting for backend service to be provisioned.."

while [ -z "$BACKEND_SERVICE_ID" ]; do
  printf "."
  export BACKEND_SERVICE_ID=$(gcloud compute backend-services list --project $PROJECT_ID \
    --filter="iap.oauth2ClientId:$CLIENT_ID AND description:spinnaker/spin-deck" --format="value(id)")

  if [ -z "$BACKEND_SERVICE_ID" ]; then
    sleep 30
  fi
done
echo ""

export AUD_CLAIM=/projects/$PROJECT_NUMBER/global/backendServices/$BACKEND_SERVICE_ID

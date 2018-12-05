#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ./properties

EXISTING_SECRET_NAME=$(kubectl get secret -n spinnaker \
  --field-selector metadata.name=="$SECRET_NAME" \
  -o json | jq .items[0].metadata.name)

echo EXISTING_SECRET_NAME=$EXISTING_SECRET_NAME

if [ $EXISTING_SECRET_NAME == 'null' ]; then
  bold "Creating Kubernetes secret $SECRET_NAME..."

read -sp 'Enter your OAuth credentials Client ID: ' CLIENT_ID
echo
read -sp 'Enter your OAuth credentials Client secret: ' CLIENT_SECRET
echo

kubectl create secret generic $SECRET_NAME -n spinnaker --from-literal=client_id=$CLIENT_ID \
  --from-literal=client_secret=$CLIENT_SECRET
else
  bold "Using existing Kubernetes secret $SECRET_NAME..."
fi

kubectl apply -f expose/backend-config.yml

# Associate deck service with backend config.
kubectl patch svc -n spinnaker spin-deck --patch \
  "[{'op': 'add', 'path': '/metadata/annotations/beta.cloud.google.com~1backend-config', \
  'value':'{\"default\": \"config-default\"}'}]" --type json

# Change spin-deck service to NodePort:
DECK_SERVICE_TYPE=$(kubectl get service -n spinnaker spin-deck \
  --output=jsonpath={.spec.type})

if [ $DECK_SERVICE_TYPE != 'NodePort' ]; then
  bold "Patching spin-deck service to be NodePort instead of $DECK_SERVICE_TYPE..."

  kubectl patch service -n spinnaker spin-deck --patch \
    "[{'op': 'replace', 'path': '/spec/type', \
    'value':'NodePort'}]" --type json
else
  bold "Service spin-deck is already NodePort..."
fi

# Create ingress:
bold $(envsubst < expose/deck-ingress.yml | kubectl apply -f -)

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

gcurl() {
  curl -s -H "Authorization:Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "X-Goog-User-Project: $PROJECT_ID" $*
}

export IAP_IAM_POLICY_ETAG=$(gcurl -X POST -d "{}" \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web:getIamPolicy | jq .etag)

cat expose/iap_policy.json | envsubst | gcurl -X POST -d @- \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web:setIamPolicy

export BACKEND_SERVICE_ID=$(gcloud compute backend-services list --project $PROJECT_ID \
  --filter="description:spinnaker/spin-deck" --format="value(id)")

echo BACKEND_SERVICE_ID=$BACKEND_SERVICE_ID

export AUD_CLAIM=/projects/$PROJECT_NUMBER/global/backendServices/$BACKEND_SERVICE_ID

echo AUD_CLAIM=$AUD_CLAIM

HALYARD_POD=$(kubectl get po -n spinnaker -l "stack=halyard" \
  -o jsonpath="{.items[0].metadata.name}")

bold "Configuring Spinnaker security settings..."

kubectl exec $HALYARD_POD -n spinnaker -- bash -c \
  "$(source ./properties && cat expose/configure_hal_security.sh | envsubst)"

# # What about CORS?

# # Wait for services to come online again (steal logic from setup.sh):

#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

pushd ~/scratch/install

source ./properties

EXISTING_SECRET_NAME=$(kubectl get secret -n spinnaker \
  --field-selector metadata.name=="$SECRET_NAME" \
  -o json | jq .items[0].metadata.name)

if [ $EXISTING_SECRET_NAME == 'null' ]; then
  bold "Creating Kubernetes secret $SECRET_NAME..."

  read -sp 'Enter your OAuth credentials Client ID: ' CLIENT_ID
  echo
  read -sp 'Enter your OAuth credentials Client secret: ' CLIENT_SECRET
  echo

  cat >~/.spin/config <<EOL
gate:
  endpoint: https://$DOMAIN_NAME/gate

auth:
  enabled: true
  iap:
    # check detailed config in https://cloud.google.com/iap/docs/authentication-howto#authenticating_from_a_desktop_app
    iapClientId: $CLIENT_ID
    serviceAccountKeyPath: "$HOME/.spin/key.json"
EOL
  gcloud iam service-accounts keys create ~/.spin/key.json \
    --iam-account $SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com \
    --project $PROJECT_ID

  kubectl create secret generic $SECRET_NAME -n spinnaker --from-literal=client_id=$CLIENT_ID \
    --from-literal=client_secret=$CLIENT_SECRET
else
  bold "Using existing Kubernetes secret $SECRET_NAME..."
  CLIENT_ID=$(kubectl get secret -n spinnaker $SECRET_NAME -o json | jq -r .data.client_id | base64 -d)
fi

envsubst < expose/backend-config.yml | kubectl apply -f -

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

unset BACKEND_SERVICE_ID

printf "Waiting for backend service to be provisioned.."

while [ -z "$BACKEND_SERVICE_ID" ]; do
  printf "."
  export BACKEND_SERVICE_ID=$(gcloud compute backend-services list --project $PROJECT_ID \
    --filter="iap.oauth2ClientId:$CLIENT_ID AND description:spinnaker/spin-deck" --format="value(id)")
  sleep 30
done
echo ""

export AUD_CLAIM=/projects/$PROJECT_NUMBER/global/backendServices/$BACKEND_SERVICE_ID

gcurl() {
  curl -s -H "Authorization:Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "X-Goog-User-Project: $PROJECT_ID" $*
}

export IAP_IAM_POLICY_ETAG=$(gcurl -X POST -d "{}" \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web/compute/services/$BACKEND_SERVICE_ID:getIamPolicy | jq .etag)

cat expose/iap_policy.json | envsubst | gcurl -X POST -d @- \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web/compute/services/$BACKEND_SERVICE_ID:setIamPolicy

bold "Configuring Spinnaker security settings..."

cat expose/configure_hal_security.sh | envsubst | bash
~/scratch/manage/push_config.sh
~/scratch/manage/apply_config.sh

../c2d/deploy_application.sh

# # What about CORS?

# # Wait for services to come online again (steal logic from setup.sh):

popd

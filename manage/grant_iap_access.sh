#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

if [ -z "$1" ]; then
  bold "Please specify the email address of the user you wish to grant the 'IAP-secured Web App User' role."
  exit 1
fi

pushd ~/scratch/install

source ./properties

~/scratch/manage/check_project_mismatch.sh

source ~/scratch/install/expose/set_iap_properties.sh

gcurl() {
  curl -s -H "Authorization:Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" -H "Accept: application/json" \
  -H "X-Goog-User-Project: $PROJECT_ID" $*
}

export EXISTING_IAM_POLICY=$(gcurl -X POST -d "{}" \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web/compute/services/$BACKEND_SERVICE_ID:getIamPolicy)

if [ "$(echo $EXISTING_IAM_POLICY | grep "\"user:$1\"")" ]; then
  bold "User $1 already has the 'IAP-secured Web App User' role."
  exit 1
fi

UPDATED_IAM_POLICY=$(echo "{}" \
  | jq --argjson existing_policy "$EXISTING_IAM_POLICY" '. += {"policy":$existing_policy}' \
  | jq ".policy.bindings[0].members += [\"user:$1\"]")

bold "Granting user $1 the 'IAP-secured Web App User' role..."

echo $UPDATED_IAM_POLICY | gcurl -X POST -d @- \
  https://iap.googleapis.com/v1beta1/projects/$PROJECT_NUMBER/iap_web/compute/services/$BACKEND_SERVICE_ID:setIamPolicy

popd

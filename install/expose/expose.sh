#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export STATIC_IP_NAME=spinnaker-external-ip
export MANAGED_CERT=spinnaker-managed-cert
export DOMAIN_NAME=spinnaker.endpoints.$PROJECT_ID.cloud.goog

export IP_ADDR=$(gcloud compute addresses list --filter="name=$STATIC_IP_NAME" \
  --format="value(address)" --global --project $PROJECT_ID)

if [ -z "$IP_ADDR" ]; then
  bold "Creating static IP address $STATIC_IP_NAME..."

  gcloud compute addresses create $STATIC_IP_NAME --global --project $PROJECT_ID

  export IP_ADDR=$(gcloud compute addresses list --filter="name=$STATIC_IP_NAME" \
    --format="value(address)" --global --project $PROJECT_ID)
else
   bold "Using existing static IP address $STATIC_IP_NAME ($IP_ADDR)..."
fi

EXISTING_SERVICE_NAME=$(gcloud endpoints services list \
  --filter="serviceName=$DOMAIN_NAME" --format="value(serviceName)" \
  --project $PROJECT_ID)

if [ -z "$EXISTING_SERVICE_NAME" ]; then
  bold "Creating service endpoint $DOMAIN_NAME..."

  cat openapi.yaml | envsubst > openapi_expanded.yaml
  gcloud endpoints services deploy openapi_expanded.yaml --project $PROJECT_ID
else
  bold "Using existing service endpoint $EXISTING_SERVICE_NAME..."
fi

EXISTING_MANAGED_CERT=$(gcloud beta compute ssl-certificates list \
  --filter="name=$MANAGED_CERT" --format="value(name)" --project $PROJECT_ID)

if [ -z "$EXISTING_MANAGED_CERT" ]; then
  bold "Creating managed SSL certificate $MANAGED_CERT for domain $DOMAIN_NAME..."

  gcloud beta compute ssl-certificates create $MANAGED_CERT --domains $DOMAIN_NAME \
    --project $PROJECT_ID
else
  bold "Using existing managed SSL certificate $EXISTING_MANAGED_CERT..."
fi



# Don't need this yet; not until configuring IAP.
# Create backend config:



# Will need to add this when configuring IAP:
#metadata:
#  annotations:
#    beta.cloud.google.com/backend-config: '{"default": "config-default"}'



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
bold $(envsubst < deck-ingress.yml | kubectl apply -f -)



# Update deck & gate to use hostname?:



# Configure IAP:



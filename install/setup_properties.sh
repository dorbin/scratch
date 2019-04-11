#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -f "properties" ]; then
  echo "The properties file already exists. Please move it out of the way if you want to generate a new properties file."
else
  # Check if Redis api is enabled.
  if [ $(gcloud services list --project $PROJECT_ID \
           --filter="config.name:redis.googleapis.com" \
           --format="value(config.name)") ]; then
    # Query existing Redis instances so we can avoid naming collisions.
    EXISTING_REDIS_NAMES=$(gcloud redis instances list --region us-west1 --project $PROJECT_ID \
                             --filter="name:spinnaker-" \
                             --format="value(name)")
    EXISTING_DEPLOYMENT_COUNT=$(echo "$EXISTING_REDIS_NAMES" | sed '/^$/d' | wc -l)
    NEW_DEPLOYMENT_SUFFIX=$(($EXISTING_DEPLOYMENT_COUNT + 1))
    NEW_DEPLOYMENT_NAME="spinnaker-$NEW_DEPLOYMENT_SUFFIX"

    while [[ "$(echo "$EXISTING_REDIS_NAMES" | grep ^$NEW_DEPLOYMENT_NAME$ | wc -l)" != "0" ]]; do
      NEW_DEPLOYMENT_NAME="spinnaker-$((++NEW_DEPLOYMENT_SUFFIX))"
    done
  else
    NEW_DEPLOYMENT_NAME="spinnaker-1"
  fi

  cat >properties <<EOL
#!/usr/bin/env bash

export PROJECT_ID=$PROJECT_ID
export DEPLOYMENT_NAME=$NEW_DEPLOYMENT_NAME

# If cluster does not exist, it will be created.
export GKE_CLUSTER=\$DEPLOYMENT_NAME
export REGION=us-west1
export ZONE=us-west1-b

export SPINNAKER_VERSION=1.12.2

# See TZ column in https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
export TIMEZONE=$(cat /etc/timezone)

# If service account does not exist, it will be created.
export SERVICE_ACCOUNT_NAME="\$DEPLOYMENT_NAME-acc-$(date +"%s")"

# If Cloud Memorystore Redis instance does not exist, it will be created.
export REDIS_INSTANCE=\$DEPLOYMENT_NAME

# If bucket does not exist, it will be created.
export BUCKET_NAME="\$DEPLOYMENT_NAME-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
export BUCKET_URI="gs://\$BUCKET_NAME"

# Used to authenticate calls to the audit log Cloud Function.
export AUDIT_LOG_UNAME="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
export AUDIT_LOG_PW="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"

export CLOUD_FUNCTION_NAME="\${DEPLOYMENT_NAME//-}AuditLog"

export GCR_PUBSUB_SUBSCRIPTION=\$DEPLOYMENT_NAME-gcr-pubsub-subscription

# The properties following this line are only relevant if you intend to expose your new Spinnaker instance.
export STATIC_IP_NAME=\$DEPLOYMENT_NAME-external-ip
export MANAGED_CERT=\$DEPLOYMENT_NAME-managed-cert
export SECRET_NAME=\$DEPLOYMENT_NAME-oauth-client-secret

# If you own a domain name and want to use that instead of this automatically-assigned one,
# specify it here (you must be able to configure the dns settings).
export DOMAIN_NAME=\$DEPLOYMENT_NAME.endpoints.$PROJECT_ID.cloud.goog

# This email address will be granted permissions as an IAP-Secured Web App User.
export IAP_USER=$(gcloud auth list --format="value(account)" --filter="status=ACTIVE")
EOL
fi

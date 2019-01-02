#!/usr/bin/env bash

if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud info --format='value(config.project)')
fi

if [ -f "properties" ]; then
  echo "The properties file already exists. Please move it out of the way if you want to generate a new properties file."
else
  cat >properties <<EOL
#!/usr/bin/env bash

export PROJECT_ID=$PROJECT_ID
# If cluster does not exist, it will be created.
export GKE_CLUSTER=spin-deployment
export REGION=us-west1
export ZONE=us-west1-b

# See TZ column in https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
export TIMEZONE=$(cat /etc/timezone)

# If service account does not exist, it will be created.
export SERVICE_ACCOUNT_NAME="spin-acc-$(date +"%s")"

# If Cloud Memorystore Redis instance does not exist, it will be created.
export REDIS_INSTANCE=spin-redis

# If bucket does not exist, it will be created.
export BUCKET_NAME="spin-gcs-bucket-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
export BUCKET_URI="gs://\$BUCKET_NAME"

# Used to authenticate calls to the audit log Cloud Function.
export AUDIT_LOG_UNAME="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
export AUDIT_LOG_PW="$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"

# The properties following this line are only relevant if you intend to expose your new Spinnaker instance.

export STATIC_IP_NAME=spinnaker-external-ip
export MANAGED_CERT=spinnaker-managed-cert
export SECRET_NAME=spinnaker-oauth-client-secret

# If you own a domain name and want to use that instead of this automatically-assigned one,
# specify it here (you must be able to configure the dns settings).
export DOMAIN_NAME=spinnaker.endpoints.$PROJECT_ID.cloud.goog

# This email address will be granted permissions as an IAP-Secured Web App User.
export IAP_USER=$(gcloud auth list --format="value(account)" --filter="status=ACTIVE")
EOL
fi

#if [ -f bucket.txt ]; then
#  export BUCKET_NAME=$(cat bucket.txt)
#else
#  export BUCKET_NAME="spin-gcs-bucket-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
#  echo $BUCKET_NAME > bucket.txt
#fi

#export BUCKET_URI="gs://$BUCKET_NAME"

#if [ -f account.txt ]; then
#  SERVICE_ACCOUNT_NAME=$(cat account.txt)
#else
#  SERVICE_ACCOUNT_NAME="spin-acc-$(date +"%s")"
#  echo $SERVICE_ACCOUNT_NAME > account.txt
#fi

#export GCS_TOPIC="spin-gcs-topic"
#export GCS_SUB="spin-gcs-sub"
#export GCR_TOPIC="projects/${PROJECT_ID}/topics/gcr"
#export GCR_SUB="spin-gcr-sub"

#export SPIN_GCS_ACCOUNT="my-gcs-account"

#export SPIN_GCS_PUB_SUB="my-gcs-pub-sub"
#export SPIN_GCR_PUB_SUB="my-gcr-pub-sub"

#export SPINNAKER_VERSION='$(hal version latest --daemon-endpoint http://spin-halyard.spinnaker:8064 -q)'

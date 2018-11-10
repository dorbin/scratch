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
export ZONE=us-west1-b

# If service account does not exist, it will be created.
export SERVICE_ACCOUNT_NAME="spin-acc-$(date +"%s")"

# If bucket does not exist, it will be created.
export BUCKET_NAME="spin-gcs-bucket-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")"
export BUCKET_URI='gs://\$BUCKET_NAME'
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

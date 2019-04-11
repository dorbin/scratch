#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ~/scratch/install/properties

GCLOUD_PROJECT_ID=$(gcloud info --format='value(config.project)')

if [ "$GCLOUD_PROJECT_ID" != $PROJECT_ID ]; then
  bold "Warn: Your Spinnaker config references GCP project id $PROJECT_ID, but your gcloud default project id is $GCLOUD_PROJECT_ID."
  bold "For safety when executing gcloud commands, you should use 'gcloud config set project $PROJECT_ID' to change the gcloud default."
fi

#!/usr/bin/env bash

hal config storage gcs edit --project $PROJECT_ID --bucket $BUCKET_NAME
hal config storage edit --type gcs

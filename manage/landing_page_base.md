# Manage Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Manage Spinnaker via Halyard from Cloud Shell

### Ensure you are connected to the correct GKE Cluster

```bash
gcloud container clusters get-credentials $GKE_CLUSTER --zone $ZONE --project $PROJECT_ID
```

### If you've already retrieved credentials, you can just select the context

```bash
kubectl config use-context gke_${PROJECT_ID}_${ZONE}_${GKE_CLUSTER}
```

### Pull all config from Spinnaker deployment into cloud shell

```bash
~/scratch/manage/pull_config.sh
```

### Configure Spinnaker via Halyard

All [halyard](https://www.spinnaker.io/reference/halyard/commands/) commands are available.
(TODO: Link to common commands.)

```bash
hal config
```

### Push updated config to Spinnaker deployment

A full backup is also stored in [this bucket](https://console.developers.google.com/storage/browser/$BUCKET_NAME/backups/?project=$PROJECT_ID).

```bash
~/scratch/manage/push_config.sh
```

### Apply updated config to Spinnaker deployment

```bash
~/scratch/manage/apply_config.sh
```

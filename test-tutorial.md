# Install Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Spinnaker Installation

Let's now provision Spinnaker within {{project-id}}. Click the Cloud Shell icon below to copy the command to your shell, and then run it from the shell by pressing Enter/Return. The Spinnaker provisioning logic will pick up the project id from the environment variable.

```bash
export PROJECT_ID={{project-id}}
```

### Configure the environment.

```bash
cd ~/scratch/install && ./setup_properties.sh
```

Verify (or modify) the environment variables that will be used for your Spinnaker installation.

<walkthrough-editor-open-file
    filePath="scratch/install/properties"
    text="Open properties file">
</walkthrough-editor-open-file>

### Begin the installation (this will take a while).

```bash
./setup.sh
```

Once the setup script completes, continue to the next step.

## Modify Spinnaker Deployment

Wait until all Spinnaker pods are up and running.

```bash
watch kubectl get po -n spinnaker
```

### Locate Halyard Pod

```bash
HALYARD_POD=$(kubectl get po -n spinnaker -l "stack=halyard" \
    -o jsonpath="{.items[0].metadata.name}")
```

### Configure Persistent Storage

```bash
kubectl exec $HALYARD_POD -n spinnaker -- bash -c "$(source ./properties &&
    cat enable_persistent_storage.sh | envsubst)"
```

### Configure Kayenta

```bash
kubectl exec $HALYARD_POD -n spinnaker -- bash -c "$(source ./properties &&
    cat enable_kayenta.sh | envsubst)"
```

## Apply Changes

Have Halyard apply the changes to the running deployment.

```bash
kubectl exec $HALYARD_POD -n spinnaker -- bash -c "hal deploy apply"
```

Again wait until all Spinnaker pods are up and running (several will be recreated).

```bash
watch kubectl get po -n spinnaker
```

## Connect to Spinnaker

### Locate Deck Pod

```bash
DECK_POD=$(kubectl -n spinnaker get pods -l cluster=spin-deck,app=spin \
    -o=jsonpath='{.items[0].metadata.name}')
```

### Forward Port to Deck

```bash
kubectl -n spinnaker port-forward $DECK_POD 8080:9000
```

### Connect to Deck

<walkthrough-spotlight-pointer
    spotlightId="devshell-web-preview-button"
    text="Connect to Spinnaker via Web Preview on 8080">
</walkthrough-spotlight-pointer>

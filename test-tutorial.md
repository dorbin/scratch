# Install Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Spinnaker Installation

Let's now provision Spinnaker within {{project-id}}. Click the Cloud Shell icon below to copy the command to your shell, and then run it from the shell by pressing Enter/Return.

### Configure the environment.

```bash
cd ~/scratch/install && PROJECT_ID={{project-id}} ./setup_properties.sh
```

Verify (or modify) the configuration that will be used for your Spinnaker installation.

<walkthrough-editor-open-file
    filePath="scratch/install/properties"
    text="Open properties file">
</walkthrough-editor-open-file>

### Begin the installation (this will take some time).

```bash
./setup.sh
```

Once the setup script completes, continue to the next step.

## Connect to Spinnaker

### Forward Port to Deck

```bash
~/scratch/manage/connect_unsecured.sh
```

### Connect to Deck

<walkthrough-spotlight-pointer
    spotlightId="devshell-web-preview-button"
    text="Connect to Spinnaker via 'Preview on port 8080'">
</walkthrough-spotlight-pointer>

### View Spinnaker Audit Log

View the who, what, when and where of your Spinnaker installation
[here](https://console.developers.google.com/logs/viewer?project={{project-id}}&resource=cloud_function&logName=projects%2F{{project-id}}%2Flogs%2FmySpinnakerAuditLog&minLogLevel=200).

### Expose Spinnaker

If you would like to connect to Spinnaker without relying on port forwarding, we can
expose it via a secure domain behind the [Identity-Aware Proxy](https://cloud.google.com/iap/).

```bash
./expose/configure_endpoint.sh
```

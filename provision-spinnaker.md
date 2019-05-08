# Install Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Spinnaker Installation

Let's now provision Spinnaker within {{project-id}}. Click the Cloud Shell icon below to copy the command to your shell, and then run it from the shell by pressing Enter/Return.

### Configure the environment.

```bash
PROJECT_ID={{project-id}} ~/scratch/install/setup_properties.sh
```

Verify (or modify) the configuration that will be used for your Spinnaker installation.

<walkthrough-editor-open-file
    filePath="scratch/install/properties"
    text="Open properties file">
</walkthrough-editor-open-file>

### Begin the installation (this will take some time).

```bash
~/scratch/install/setup.sh
```

Once the setup script completes, continue to the next step.

## Connect to Spinnaker

### Forward Port to Deck

```bash
~/scratch/manage/connect_unsecured.sh
```

Do not use the `hal deploy connect` command, as this will result in two ports, 8084 and 9000, being forwarded from your shell. Cloud Shell can only expose one port for preview,
so you'll need to use the connect_unsecured.sh command instead.

### Connect to Deck

<walkthrough-spotlight-pointer
    spotlightId="devshell-web-preview-button"
    text="Connect to Spinnaker via 'Preview on port 8080'">
</walkthrough-spotlight-pointer>

### View Spinnaker Audit Log

View the who, what, when and where of your Spinnaker installation
[here](https://console.developers.google.com/logs/viewer?project={{project-id}}&resource=cloud_function&minLogLevel=200).

### Expose Spinnaker

If you would like to connect to Spinnaker without relying on port forwarding, we can
expose it via a secure domain behind the [Identity-Aware Proxy](https://cloud.google.com/iap/).

```bash
~/scratch/install/expose/configure_endpoint.sh
```

### Manage & Share Spinnaker

Now that Spinnaker has been provisioned, next steps can be found via this landing page:

```bash
teachme ~/scratch/manage/landing_page_expanded.md
```

### Ongoing Management

When you want to manage Spinnaker in the future, you can always locate your Spinnaker installation
by navigating to the newly-registered Kubernetes Application via the [Applications](https://console.developers.google.com/kubernetes/application?project={{project-id}}) view.

The application's *Next Steps* section contains the relevant links and operator instructions.
# Manage Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Manage Spinnaker via Halyard from Cloud Shell

### Ensure you are connected to the correct Kubernetes context

```bash
PROJECT_ID={{project-id}} ~/scratch/manage/check_cluster_config.sh
```

### Pull all config from Spinnaker deployment into cloud shell

```bash
~/scratch/manage/pull_config.sh
```

### Update the console

#### (This is a required step if you've just pulled config from a different Spinnaker deployment.)

This will include details on connecting to Spinnaker.

```bash
~/scratch/manage/update_console.sh
```

### Configure Spinnaker via Halyard

All [halyard](https://www.spinnaker.io/reference/halyard/commands/) commands are available.

```bash
hal config
```

### Notes on Halyard commands that reference local files

If you add a kubernetes account that references a kubeconfig file (specified via the `--kubeconfig-file`
argument to the `hal config provider kubernetes account add/edit` commands), that file must live within
the '`~/.hal/default/credentials`' directory on your cloud shell vm. The `default` path segment should
be changed if you are using a different name for your deployment.

Same requirement for any Google json key file specified via the `--json-path` argument to various commands.

### Push updated config to Spinnaker deployment

```bash
~/scratch/manage/push_config.sh
```

### Apply updated config to Spinnaker deployment

```bash
~/scratch/manage/apply_config.sh
```

## Scripts for Common Commands

### Halyard CLI

The Halyard CLI (`hal`) and daemon are installed in your Cloud Shell. If you want to use a specific version of Halyard, you must use
`~/scratch/install_hal.sh`. If you want to upgrade to the latest version of Halyard, you must use `~/scratch/update_hal.sh`.

### Spinnaker CLI

The Spinnaker CLI (`spin`) is installed in your Cloud Shell. If you want to upgrade to the latest version, you must use `~/scratch/install_spin.sh`.

### Add Spinnaker account for GKE

Prior to running this command, you must ensure that you have configured the context you intend to use to manage your GKE resources.

The public Spinnaker documentation contains details on [configuring GKE clusters](https://www.spinnaker.io/setup/install/providers/kubernetes-v2/gke/).

```bash
~/scratch/manage/add_gke_account.sh
```

### Add Spinnaker account for GCE

```bash
~/scratch/manage/add_gce_account.sh
```

### Connect to Redis

```bash
~/scratch/manage/connect_to_redis.sh
```

## Configure Operator Access

To add additional operators, grant them the `Owner` role on GCP Project {{project-id}}: [IAM Permissions](https://console.developers.google.com/iam-admin/iam?project={{project-id}})

Once they have been added to the project, they can locate Spinnaker by navigating to the newly-registered [Kubernetes Application](https://console.developers.google.com/kubernetes/application/$ZONE/$DEPLOYMENT_NAME/spinnaker/$DEPLOYMENT_NAME?project={{project-id}}).

The application's *Next Steps* section contains the relevant links and operator instructions.


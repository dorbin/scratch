# Manage Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Manage Spinnaker via Halyard from Cloud Shell

### Pull all config from Spinnaker deployment into cloud shell

```bash
~/scratch/manage/pull_config.sh
```

### Reload this tutorial

#### (This is a required step if you've just pulled config from a different Spinnaker.)

This will include details on connecting to Spinnaker.

```bash
teachme ~/scratch/manage/landing_page_expanded.md
```

### Configure Spinnaker via Halyard

All [halyard](https://www.spinnaker.io/reference/halyard/commands/) commands are available.
(TODO: Link to common commands.)

```bash
hal config
```

### Notes on Halyard commands that reference local files

(TODO: Add notes...)

If you add a kubernetes account that references a kubeconfig file (specified via the `--kubeconfig-file`
argument to the `hal config provider kubernetes account add/edit` commands), that file must live within
the '`~/.hal/default/credentials`' directory on your cloud shell vm. The `default` path segment should
be changed if you are using a different name for your deployment.

Same requirement for any Google json key file specified via the `--json-path` argument various commands.

### Push updated config to Spinnaker deployment

```bash
~/scratch/manage/push_config.sh
```

### Apply updated config to Spinnaker deployment

```bash
~/scratch/manage/apply_config.sh
```

## Configure Operator Access

To add additional operators, grant them the `Owner` role on GCP Project {{project-id}}: [IAM Permissions](https://console.developers.google.com/iam-admin/iam?project={{project-id}})

Once they have been added to the project, they can locate Spinnaker by navigating to the newly-registered [Kubernetes Application](https://console.developers.google.com/kubernetes/application/$ZONE/$DEPLOYMENT_NAME/spinnaker/$DEPLOYMENT_NAME?project={{project-id}}).

The application's *Next Steps* section contains the relevant links and operator instructions.


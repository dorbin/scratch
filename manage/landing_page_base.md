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

### Push updated config to Spinnaker deployment

```bash
~/scratch/manage/push_config.sh
```

### Apply updated config to Spinnaker deployment

```bash
~/scratch/manage/apply_config.sh
```

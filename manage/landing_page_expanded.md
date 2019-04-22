# Manage Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup>
</walkthrough-project-billing-setup>

## Manage Spinnaker via Halyard from Cloud Shell

### Ensure command-line tools are installed

You can skip this step if you are the original installer/operator, as they will have already been installed.

```bash
~/scratch/install_hal.sh && ~/scratch/install_spin.sh && source ~/.bashrc
```

### Pull all config from Spinnaker deployment into cloud shell

```bash
~/scratch/manage/pull_config.sh
```

### Reload this tutorial

This will include details on connecting to Spinnaker.

```bash
teachme ~/scratch/manage/landing_page_expanded.md
```

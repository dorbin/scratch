# Install Spinnaker

## GCP Project Selection

<walkthrough-project-billing-setup></walkthrough-project-billing-setup>

## Spinnaker Installation

Let's now provision Spinnaker within {{project-id}}. Click the Cloud Shell icon below to copy the command to your shell, and then run it from the shell by pressing Enter/Return. The Spinnaker provisioning logic will pick up the project id from the environment variable.

```bash
export PROJECT_ID={{project-id}}
```

Configure the environment.

```bash
# Protect existing properties file
cd ~/scratch/install && ./setup_properties.sh
```

Verify (or modify) the environment variables that will be used for your Spinnaker installation.

<walkthrough-editor-open-file filePath="scratch/install/properties"
                              text="Open properties file">
</walkthrough-editor-open-file>

Begin the installation (this will take a while).

```bash
./setup.sh
```

### Part 3

Part Three Instructions.

### Part 4

Part Four Instructions.

## Conclusion

Done!

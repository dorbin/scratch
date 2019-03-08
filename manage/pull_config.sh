#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export HALYARD_POD=spin-halyard-0

# Remove local config so persistent config from Halyard Daemon pod can be copied into place.
bold "Removing $HOME/.hal..."
rm -rf ~/.hal

# Copy persistent config into place.
bold "Copying spinnaker/$HALYARD_POD:/home/spinnaker/.hal into $HOME/.hal..."
kubectl cp spinnaker/$HALYARD_POD:/home/spinnaker/.hal ~/.hal

grep kubeconfigFile ~/.hal/config &> /dev/null
FOUND_TOKEN=$?

if [ "$FOUND_TOKEN" == "0" ]; then
  bold "Rewriting kubeconfigFile path to reflect local user '$USER' on Cloud Shell VM..."
  sed -i "s/kubeconfigFile: \/home\/spinnaker/kubeconfigFile: \/home\/$USER/" ~/.hal/config
fi

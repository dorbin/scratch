#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

HALYARD_POD=spin-halyard-0

TEMP_DIR=$(mktemp -d -t halyard.XXXXX)
pushd $TEMP_DIR

mkdir .hal

# Remove local config so persistent config from Halyard Daemon pod can be copied into place.
bold "Removing $HOME/.hal..."
rm -rf ~/.hal

# Copy persistent config into place.
bold "Copying spinnaker/$HALYARD_POD:/home/spinnaker/.hal into $HOME/.hal..."

kubectl cp spinnaker/$HALYARD_POD:/home/spinnaker/.hal .hal

grep kubeconfigFile .hal/config &> /dev/null
FOUND_TOKEN=$?

if [ "$FOUND_TOKEN" == "0" ]; then
  bold "Rewriting kubeconfigFile path to reflect local user '$USER' on Cloud Shell VM..."
  sed -i "s/kubeconfigFile: \/home\/spinnaker/kubeconfigFile: \/home\/$USER/" .hal/config
fi

# We want just these subdirs from the Halyard Daemon pod to be copied into place in ~/.hal.
DIRS=(credentials profiles service-settings)

for p in "${DIRS[@]}"; do
  for f in $(find .hal/*/$p -prune 2> /dev/null); do
    SUB_PATH=$(echo $f | rev | cut -d '/' -f 1,2 | rev)
    mkdir -p ~/.hal/$SUB_PATH
    cp -R .hal/$SUB_PATH/* ~/.hal/$SUB_PATH
  done
done

cp .hal/config ~/.hal

popd
rm -rf $TEMP_DIR

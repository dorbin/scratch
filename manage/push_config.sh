#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ~/scratch/install/properties

HALYARD_POD=spin-halyard-0

TEMP_DIR=$(mktemp -d -t halyard.XXXXX)
pushd $TEMP_DIR

mkdir .hal

# We want just these subdirs within ~/.hal to be copied into place on the Halyard Daemon pod.
DIRS=(credentials profiles service-settings)

for p in "${DIRS[@]}"; do
  for f in $(find ~/.hal/*/$p -prune 2> /dev/null); do
    SUB_PATH=$(echo $f | rev | cut -d '/' -f 1,2 | rev)
    mkdir -p .hal/$SUB_PATH
    cp -R ~/.hal/$SUB_PATH/* .hal/$SUB_PATH
  done
done

cp ~/.hal/config .hal

grep kubeconfigFile .hal/config &> /dev/null
FOUND_TOKEN=$?

if [ "$FOUND_TOKEN" == "0" ]; then
  bold "Rewriting kubeconfigFile path to reflect user 'spinnaker' on Halyard Daemon pod..."
  sed -i "s/kubeconfigFile: \/home\/$USER/kubeconfigFile: \/home\/spinnaker/" .hal/config
fi

HALCONFIG_ARCHIVE_FILENAME=halconfig-$(date +%Y%m%d%H%M%S -u).tar.gz
bold "Backing up $HOME/.hal to $BUCKET_URI/backups/$HALCONFIG_ARCHIVE_FILENAME..."
tar cfz $HALCONFIG_ARCHIVE_FILENAME .hal
gsutil -q cp $HALCONFIG_ARCHIVE_FILENAME $BUCKET_URI/backups/$HALCONFIG_ARCHIVE_FILENAME

# Remove old persistent config so new config can be copied into place.
bold "Removing spinnaker/$HALYARD_POD:/home/spinnaker/.hal..."
kubectl -n spinnaker exec -it $HALYARD_POD -- bash -c "rm -rf ~/.hal/*"

# Copy new config into place.
bold "Copying $HOME/.hal into spinnaker/$HALYARD_POD:/home/spinnaker/.hal..."
kubectl -n spinnaker cp $TEMP_DIR/.hal spin-halyard-0:/home/spinnaker

popd
rm -rf $TEMP_DIR

# TODO(duftler): Add dry-run.
# TODO(duftler): Add 'hal deploy apply' option.

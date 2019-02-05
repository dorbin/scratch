#!/usr/bin/env bash

flatten() {
  MOUNT_PATH=$(echo $1 | sed "s/home\/$USER/home\/spinnaker\/staging/")
  SUB_PATH=$(echo $1 | rev | cut -d '/' -f 1 | rev)

  # Check for filename collision at destination. If present, prefix with hash of filepath.
  if [ -f "config-dir/$SUB_PATH" ]; then
    SUB_PATH="$(echo $1 | md5sum | cut -f 1 -d " ")-$SUB_PATH"
  fi

  cp $1 config-dir/$SUB_PATH

  cat >>$VOLUME_MOUNTS_JSON_PATCH_FILE <<EOL
  {
    "name": "halconfig",
    "mountPath": "$MOUNT_PATH",
    "subPath": "$SUB_PATH"
  },
EOL
}

open_volume_mounts_patch_file() {
  cat >>$VOLUME_MOUNTS_JSON_PATCH_FILE <<EOL
[
  {
    "name": "persistentconfig",
    "mountPath": "/home/spinnaker/.hal"
  },
  {
    "name": "halconfig",
    "mountPath": "/home/spinnaker/staging/.hal/config",
    "subPath": "config"
  },
EOL
}

close_volume_mounts_patch_file() {
  echo "]" >> $VOLUME_MOUNTS_JSON_PATCH_FILE
}

TEMP_DIR=$(mktemp -d -t halyard.XXXXX)
pushd $TEMP_DIR

VOLUME_MOUNTS_JSON_PATCH_FILE=patch-file-volume-mounts.json

mkdir config-dir
cp ~/.hal/config config-dir
open_volume_mounts_patch_file

DIRS=(profiles service-settings)
for p in "${DIRS[@]}"; do
  for f in $(find ~/.hal/*/$p -type f); do
    flatten $f;
  done
done

close_volume_mounts_patch_file

CONFIG_MAP_NAME=halconfig-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 20 | head -n 1)-$(date +"%s")
HALYARD_POD=spin-halyard-0

# Create the new config map.
kubectl create cm -n spinnaker $CONFIG_MAP_NAME --from-file $TEMP_DIR/config-dir

# Remove old persistent config so staged config will be copied into place.
kubectl -n spinnaker exec -it $HALYARD_POD -- bash -c "rm -rf ~/.hal/*"

# Update the statefulset with the new volume mounts and config map.
kubectl patch statefulset -n spinnaker spin-halyard --patch \
  "[{'op': 'replace', 'path': '/spec/template/spec/containers/0/volumeMounts', \
  'value':$(cat $TEMP_DIR/patch-file-volume-mounts.json)}, {'op': 'replace', \
  'path': '/spec/template/spec/volumes/0', 'value':{'name':'halconfig',\
  'configMap':{'name':'$CONFIG_MAP_NAME'}}}]" --type json

statefulset_ready() {
  printf "Waiting on $2 to restart"
  while [[ "$(kubectl get statefulset $1 -n spinnaker -o \
            jsonpath="{.status.readyReplicas}")" != \
           "$(kubectl get statefulset $1 -n spinnaker -o \
            jsonpath="{.status.replicas}")" ]]; do
    printf "."
    sleep 5
  done
  echo ""
}

statefulset_ready spin-halyard "Halyard"

popd

# TODO: Remove temp dir.
# TODO: Add dry-run.
# TODO: Add 'hal deploy apply' option.


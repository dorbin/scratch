#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ~/scratch/install/properties

CURRENT_CONTEXT_CLUSTER=$(kubectl config current-context | rev | cut -d '_' -f 1 | rev)

if [ $CURRENT_CONTEXT_CLUSTER != $GKE_CLUSTER ]; then
  bold "Your Spinnaker config references cluster $GKE_CLUSTER, but you are connected to cluster $CURRENT_CONTEXT_CLUSTER."
  bold "Use 'kubectl config use-context' to connect to the correct cluster before pushing the config."
  exit 1
fi

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
    cp -RT ~/.hal/$SUB_PATH .hal/$SUB_PATH
  done
done

cp ~/.hal/config .hal

REWRITABLE_KEYS=(kubeconfigFile jsonPath)
for k in "${REWRITABLE_KEYS[@]}"; do
  grep $k .hal/config &> /dev/null
  FOUND_TOKEN=$?

  if [ "$FOUND_TOKEN" == "0" ]; then
    bold "Rewriting $k path to reflect user 'spinnaker' on Halyard Daemon pod..."
    sed -i "s/$k: \/home\/$USER/$k: \/home\/spinnaker/" .hal/config
  fi
done

TIMESTAMP=$(date +%Y%m%d%H%M%S -u)
HALCONFIG_ARCHIVE_FILENAME=halconfig-$TIMESTAMP.tar.gz
bold "Backing up $HOME/.hal to $BUCKET_URI/backups/$HALCONFIG_ARCHIVE_FILENAME..."
tar cfz $HALCONFIG_ARCHIVE_FILENAME .hal
gsutil -q cp $HALCONFIG_ARCHIVE_FILENAME $BUCKET_URI/backups/$HALCONFIG_ARCHIVE_FILENAME

mkdir deployment_config_files

copy_if_exists() {
  if [ -e $1 ]; then
    cp $1 $2
  fi
}

copy_if_exists ~/scratch/install/properties deployment_config_files
copy_if_exists ~/scratch/install/spinnakerAuditLog/config.json deployment_config_files
copy_if_exists ~/scratch/install/spinnakerAuditLog/index.js deployment_config_files
copy_if_exists ~/scratch/install/expose/configure_iap_expanded.md deployment_config_files
copy_if_exists ~/scratch/install/expose/openapi_expanded.yml deployment_config_files
copy_if_exists ~/scratch/manage/landing_page_expanded.md deployment_config_files
copy_if_exists ~/.spin/config deployment_config_files
copy_if_exists ~/.spin/key.json deployment_config_files

DEPLOYMENT_CONFIG_ARCHIVE_FILENAME=deployment-config-$TIMESTAMP.tar.gz
bold "Backing up Spinnaker deployment config files to $BUCKET_URI/backups/$DEPLOYMENT_CONFIG_ARCHIVE_FILENAME..."
tar cfz $DEPLOYMENT_CONFIG_ARCHIVE_FILENAME -C deployment_config_files $(ls deployment_config_files)
  
gsutil -q cp $DEPLOYMENT_CONFIG_ARCHIVE_FILENAME $BUCKET_URI/backups/$DEPLOYMENT_CONFIG_ARCHIVE_FILENAME

# Remove old persistent config so new config can be copied into place.
bold "Removing spinnaker/$HALYARD_POD:/home/spinnaker/.hal..."
kubectl -n spinnaker exec -it $HALYARD_POD -- bash -c "rm -rf ~/.hal/*"

# Copy new config into place.
bold "Copying $HOME/.hal into spinnaker/$HALYARD_POD:/home/spinnaker/.hal..."
kubectl -n spinnaker cp $TEMP_DIR/.hal spin-halyard-0:/home/spinnaker

EXISTING_DEPLOYMENT_SECRET_NAME=$(kubectl get secret -n spinnaker \
  --field-selector metadata.name=="spinnaker-deployment" \
  -o json | jq .items[0].metadata.name)

if [ $EXISTING_DEPLOYMENT_SECRET_NAME != 'null' ]; then
  bold "Deleting Kubernetes secret spinnaker-deployment..."
  kubectl delete secret spinnaker-deployment -n spinnaker
fi

bold "Creating Kubernetes secret spinnaker-deployment containing Spinnaker deployment config files..."
kubectl create secret generic spinnaker-deployment -n spinnaker \
  --from-file deployment_config_files

popd
rm -rf $TEMP_DIR

# TODO(duftler): Add 'hal deploy apply' option.

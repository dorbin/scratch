#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ./properties

export HALYARD_POD=$(kubectl -n spinnaker get pods -l \
    stack=halyard,app=spin \
    -o=jsonpath='{.items[0].metadata.name}')

kubectl cp spinnaker/$HALYARD_POD:/home/spinnaker/.hal ~/.hal


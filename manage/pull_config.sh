#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export HALYARD_POD=spin-halyard-0

# TODO(duftler): First remove ~/.hal?
kubectl cp spinnaker/$HALYARD_POD:/home/spinnaker/.hal ~/.hal


#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

export HALYARD_POD=spin-halyard-0

bold "Removing $HOME/.hal..."
rm -rf ~/.hal

bold "Copying spinnaker/$HALYARD_POD:/home/spinnaker/.hal into $HOME/.hal..."
kubectl cp spinnaker/$HALYARD_POD:/home/spinnaker/.hal ~/.hal

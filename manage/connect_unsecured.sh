#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

bold "Locating Deck pod..."

DECK_POD=$(kubectl -n spinnaker get pods -l cluster=spin-deck,app=spin \
  -o=jsonpath='{.items[0].metadata.name}')

bold "Forwarding localhost port 8080 to 9000 on $DECK_POD..."

pkill -f 'kubectl -n spinnaker port-forward'
kubectl -n spinnaker port-forward $DECK_POD 8080:9000 > /dev/null 2>&1 &

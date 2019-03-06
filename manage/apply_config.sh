#!/usr/bin/env bash

HALYARD_POD=spin-halyard-0

kubectl exec $HALYARD_POD -n spinnaker -- bash -c 'hal deploy apply'

~/scratch/c2d/deploy_application.sh

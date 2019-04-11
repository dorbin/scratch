#!/usr/bin/env bash

HALYARD_POD=spin-halyard-0

kubectl exec $HALYARD_POD -n halyard -- bash -c 'hal deploy apply'

~/scratch/c2d/deploy_application.sh

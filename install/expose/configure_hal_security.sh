#!/usr/bin/env bash

hal config security api edit --override-base-url https://$DOMAIN_NAME/gate
hal config security ui edit --override-base-url https://$DOMAIN_NAME
hal config security authn iap edit --audience $AUD_CLAIM
hal config security authn iap
hal deploy apply

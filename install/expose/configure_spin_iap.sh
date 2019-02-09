#!/usr/bin/env bash

bold() {
  echo ". $(tput bold)" "$*" "$(tput sgr0)";
}

source ./properties

read -sp 'Enter your authorization code: ' AUTHORIZATION_CODE
echo

bold "Generating IAP ID Token..."

REFRESH_TOKEN=$(curl -s --data client_id=$OTHER_IAP_CLIENT_ID \
     --data client_secret=$OTHER_IAP_CLIENT_SECRET \
     --data code=$AUTHORIZATION_CODE \
     --data redirect_uri=urn:ietf:wg:oauth:2.0:oob \
     --data grant_type=authorization_code \
     https://www.googleapis.com/oauth2/v4/token | jq -r .refresh_token)

IAP_ID_TOKEN=$(curl -s --data client_id=$OTHER_IAP_CLIENT_ID \
     --data client_secret=$OTHER_IAP_CLIENT_SECRET \
     --data refresh_token=$REFRESH_TOKEN \
     --data grant_type=refresh_token \
     --data audience=$IAP_CLIENT_ID \
     https://www.googleapis.com/oauth2/v4/token | jq -r .id_token)

sed -i '/^    iapIdToken:.*/d' ~/.spin/config
sed -i "/^    iapClientId:.*/a\    iapIdToken: $IAP_ID_TOKEN" ~/.spin/config

bold "Done."
bold "Try it out with commands like: spin application list"

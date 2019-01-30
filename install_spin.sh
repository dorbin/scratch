#!/usr/bin/env bash

curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin

chmod +x spin
mv spin ~

grep -q '^alias spin=~/spin' ~/.bashrc || echo 'alias spin=~/spin' >> ~/.bashrc

if [ -f "$HOME/.spin/config" ]; then
  mv ~/.spin/config ~/.spin/config.bak
else
  mkdir -p ~/.spin
fi

cat >~/.spin/config <<EOL
gate:
  endpoint: http://localhost:8080/gate
EOL

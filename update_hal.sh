#!/usr/bin/env bash

sudo ~/hal/update-halyard

mkdir -p ~/hal/log
sudo mv /usr/local/bin/hal ~/hal
sudo mv /opt/halyard ~/hal
sudo mv /usr/local/bin/update-halyard ~/hal

sed -i 's:^. /etc/bash_completion.d/hal:# . /etc/bash_completion.d/hal\n. ~/hal/hal_completion\nalias hal=~/hal/hal:' ~/.bashrc
sed -i s:/opt/halyard:~/hal/halyard:g ~/hal/hal
sed -i s:/var/log/spinnaker/halyard:~/hal/log:g ~/hal/hal
sudo sed -i s:/opt/spinnaker:~/hal/spinnaker:g ~/hal/halyard/bin/halyard
sed -i 's:rm -rf /opt/halyard:rm -rf /home/duftler/hal/halyard:g' ~/hal/update-halyard
sed -i s:/opt/spinnaker:/home/duftler/hal/spinnaker:g ~/hal/update-halyard
sed -i s:/etc/bash_completion.d/hal:/home/duftler/hal/hal_completion: ~/hal/update-halyard


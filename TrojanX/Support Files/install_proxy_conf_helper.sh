#!/bin/sh

#  install_proxy_conf_helper.sh
#  TrojanX
#
#  Created by Sakurai on 2019/12/31.
#  Copyright © 2019 Sakurai. All rights reserved.

cd "$(dirname "${BASH_SOURCE[0]}")"

sudo mkdir -p "/Library/Application Support/TrojanX/"
sudo cp proxy_conf_helper "/Library/Application Support/TrojanX/"
sudo chown root:admin "/Library/Application Support/TrojanX/proxy_conf_helper"
sudo chmod a+rx "/Library/Application Support/TrojanX/proxy_conf_helper"
sudo chmod +s "/Library/Application Support/TrojanX/proxy_conf_helper"

echo done

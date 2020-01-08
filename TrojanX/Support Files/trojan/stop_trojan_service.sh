#!/bin/sh

#  stop_trojan_service.sh
#  Trojan
#
#  Created by Sakurai on 2019/12/29.
#  Copyright © 2019 Sakurai. All rights reserved.

launchctl stop com.huimingz.TrojanX.trojan
launchctl unload "$HOME/Library/Application Scripts/com.huimingz.TrojanX/com.huimingz.TrojanX.trojan.plist"

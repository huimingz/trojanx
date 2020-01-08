#!/bin/sh

#  start_trojan_service.sh
#  Trojan
#
#  Created by Sakurai on 2019/12/29.
#  Copyright © 2019 Sakurai. All rights reserved.

chmod 644 "$HOME/Library/Application Scripts/com.huimingz.TrojanX/com.huimingz.TrojanX.trojan.plist"
launchctl load -wF "$HOME/Library/Application Scripts/com.huimingz.TrojanX/com.huimingz.TrojanX.trojan.plist"
launchctl start com.huimingz.TrojanX.trojan

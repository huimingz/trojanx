#!/bin/sh

#  start_privoxy.sh
#  ShadowsocksX-NG
#
#  Created by 王晨 on 16/10/7.
#  Copyright © 2016年 zhfish. All rights reserved.

chmod 644 "$HOME/Library/LaunchAgents/com.huimingz.TrojanX.proxy.plist"
launchctl load -wF "$HOME/Library/LaunchAgents/com.huimingz.TrojanX.proxy.plist"
launchctl start com.huimingz.TrojanX.proxy

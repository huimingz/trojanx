//
//  MainMenuController.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/30.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Cocoa

var isRunning = false

class MainMenuController: NSMenu, NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        NSLog("Menu will Open")
    }
}

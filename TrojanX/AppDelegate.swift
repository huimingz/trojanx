//
//  AppDelegate.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/30.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, ServerPreferencesWindowDelegate, PreferencesWindowDelegate, UserRulesWindowDelgate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var serviceStatus: NSMenuItem!
    @IBOutlet weak var trojanXServiceSwitch: NSMenuItem!
    @IBOutlet weak var autoPacModeMenuItem: NSMenuItem!
    @IBOutlet weak var globalMenuItem: NSMenuItem!
    @IBOutlet weak var serverListMenuItem: NSMenuItem!
    @IBOutlet weak var serverProfilesBeginSeparatorMenuItem: NSMenuItem!
    @IBOutlet weak var serverProfilesEndSeparatorMenuItem: NSMenuItem!
    
    var serverPreferencesWindow: ServerPreferencesWindow!
    var preferencesWindow: PreferencesWindow!
    var editUserRulesWindow: UserRulesWindow!
    
    var isRunning = false {
        didSet {
            self.serviceStatus.title = isRunning ? "Status: ON" : "Status: OFF"
            self.trojanXServiceSwitch.title = isRunning ? "Turn Trojan Off" : "Turn Trojan On"
        }
    }
    
    var runningMode: ProxyConfHelper.Mode = PreferencePlist.trojanRunningMode {
        didSet {
            PreferencePlist.trojanRunningMode = self.runningMode
        }
    }
    
    var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        UserDefaults.standard.register(defaults: [
            PreferencePlist.KEY_TROJAN_SOCKS5_LISTEN_ADDR: "127.0.0.1",
            PreferencePlist.KEY_TROJAN_SOCKS5_LISTEN_PORT: 1080,
            PreferencePlist.KEY_PAC_SERVER_LISTEN_ADDR: "127.0.0.1",
            PreferencePlist.KEY_PAC_SERVER_LISTEN_PORT: 1089,
            PreferencePlist.KEY_RUNNING_MODE: ProxyConfHelper.Mode.auto.rawValue,
            PreferencePlist.KEY_HIDE_DOCK_APP_ICON: true,
            PreferencePlist.KEY_TROJAN_TCP_NO_DELY: true,
            PreferencePlist.KEY_TROJAN_TCP_KEEP_ALIVE: true,
            PreferencePlist.KEY_TROJAN_TCP_REUSE_PORT: false,
            PreferencePlist.KEY_TROJAN_TCP_FAST_OPEN: false,
            PreferencePlist.KEY_TROJAN_TCP_FAST_OPEN_QLEN: 20,
            PreferencePlist.KEY_TROJAN_LOG_LEVEL: PreferencePlist.trojanLogLevel.info.rawValue
        ])
        
        statusItem.button?.title = "hello"
        statusItem.button?.image = NSImage(named: "icon")
        statusItem.menu = statusMenu
        statusMenu.delegate = self
        
        switch self.runningMode {
        case .auto:
            self.autoPacModeMenuItem.state = .on
        case .global:
            self.globalMenuItem.state = .on
        case .off:
            self.autoPacModeMenuItem.state = .off
            self.globalMenuItem.state = .off
        }
        
        ProxyConfHelper.install()
        updateServerListMenu()
        
        // Set dock icon to show or hide.
        if !PreferencePlist.hideDockAppIcon {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        stopTrojan()
        ProxyConfHelper.turnDownProxyMode()
    }
    
    @IBAction func toggleRunning(_ sender: NSMenuItem) {
        if !self.isRunning{
            self.isRunning = true
            startTrojanProxy()
        } else {
            self.isRunning = false
            stopTrojanProxy()
        }
    }
    
    @IBAction func demoGenerateTrojanPlist(_ sender: NSMenuItem) {
        //        let _ = gererateTrojanConfig()
        NSApp.setActivationPolicy(.prohibited)
    }
    
    @IBAction func demoLaunchTrojanService(_ sender: Any) {
        NSApp.setActivationPolicy(.regular)
    }
    
    @IBAction func selectAutoPACMode(_ sender: NSMenuItem) {
        self.runningMode = ProxyConfHelper.Mode.auto
        self.globalMenuItem.state = .off
        self.autoPacModeMenuItem.state = .on
        
        // switch proxy mode to auto pac mode if the trojan is running.
        if self.isRunning {
            ProxyConfHelper.autoProxy()
        }
    }
    
    @IBAction func selectGlobalMode(_ sender: NSMenuItem) {
        self.runningMode = ProxyConfHelper.Mode.global
        self.globalMenuItem.state = .on
        self.autoPacModeMenuItem.state = .off
        
        if self.isRunning {
            ProxyConfHelper.socks5GlobalMode()
        }
    }
    
    @IBAction func showServerPreferencesWindow(_ sender: NSMenuItem) {
        if self.serverPreferencesWindow != nil {
            NSApp.activate(ignoringOtherApps: true)
            self.serverPreferencesWindow.window?.makeKeyAndOrderFront(self)
        } else {
            self.serverPreferencesWindow = ServerPreferencesWindow(windowNibName: "ServerPreferencesWindow")
            self.serverPreferencesWindow.showWindow(self)
            self.serverPreferencesWindow.delegate = self
            NSApp.activate(ignoringOtherApps: true)
            self.serverPreferencesWindow.window?.makeKeyAndOrderFront(self)
        }
    }
    
    @IBAction func showPreferencesWindow(_ sender: Any!) {
        if self.preferencesWindow != nil {
            self.preferencesWindow.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            self.preferencesWindow = PreferencesWindow(windowNibName: "PreferencesWindow")
            self.preferencesWindow.showWindow(self)
            self.preferencesWindow.delegate = self
            NSApp.activate(ignoringOtherApps: true)
            self.preferencesWindow.window?.makeKeyAndOrderFront(self)
        }
    }
    
    @IBAction func showEditUserRulesWindow(_ sender: NSMenuItem) {
        if self.editUserRulesWindow != nil {
            self.editUserRulesWindow.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            self.editUserRulesWindow = UserRulesWindow(windowNibName: "UserRulesWindow")
            self.editUserRulesWindow.showWindow(self)
            self.editUserRulesWindow.delegate = self
            self.editUserRulesWindow.window?.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @IBAction func socks5ProxyExportToPastedBoard(_ sender: NSMenuItem) {
        let addr = PreferencePlist.localSocks5ListenAddr
        let port = PreferencePlist.localSocks5ListenPort
        
        var command = "export http_proxy=socks5://\(addr):\(port); "
        command += "export https_proxy=socks5://\(addr):\(port)"
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(command, forType: .string)
        
        let notify = NSUserNotification()
        notify.title = "Successful"
        notify.informativeText = "Export Command Copied."
        notify.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notify)
    }
    
    @IBAction func clickHotUpdatePACServer(_ sender: NSMenuItem) {
        let _ = GeneratePACFile()
        ProxyConfHelper.turnDownProxyMode()
        ProxyConfHelper.autoProxy()
        
        let notify = NSUserNotification()
        notify.title = "Success".localized
        notify.informativeText = "Update PAC file and restart PAC server".localized
        notify.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notify)
    }
    
    @objc func updateServerListMenu() {
        guard let menu = self.serverListMenuItem.submenu else {
            return
        }
        
        // Remove all profile menu items
        let beginIdx = menu.index(of: self.serverProfilesBeginSeparatorMenuItem) + 1
        let endIdx = menu.index(of: self.serverProfilesEndSeparatorMenuItem)
        for i in (beginIdx..<endIdx).reversed() {
            menu.removeItem(at: i)
        }
        
        // Insert all profile menu items
        let trojanProfiles = PreferencePlist.trojanServerProfileList
        for (i, profile) in trojanProfiles.enumerated().reversed() {
            let uid = profile[PreferencePlist.KEY_TROJAN_PROFILE_UID] as? String ?? ""
            if uid.isEmpty {
                continue
            }
            
            let subMenu = NSMenuItem()
            subMenu.identifier = NSUserInterfaceItemIdentifier(uid)
            subMenu.tag = i
            subMenu.title = profile[PreferencePlist.KEY_TROJAN_PROFILE_REMARK] as? String ?? "Unknow"
            if let uid = profile[PreferencePlist.KEY_TROJAN_PROFILE_UID] as? String, uid == PreferencePlist.activeServerProfileUID {
                subMenu.state = .on
                self.serverListMenuItem.title = profile[PreferencePlist.KEY_TROJAN_PROFILE_REMARK] as? String ?? "Unknow"
            } else {
                subMenu.state = .off
            }
            subMenu.action = #selector(AppDelegate.selectServer(_:))
            menu.insertItem(subMenu, at: beginIdx)
        }
        
        self.serverProfilesEndSeparatorMenuItem.isHidden = trojanProfiles.isEmpty
    }
    
    @objc func selectServer(_ sender: NSMenuItem) {
        NSLog("select server \(String(describing: sender.identifier?.rawValue))")
        if let uid = sender.identifier?.rawValue, !uid.isEmpty {
            PreferencePlist.activeServerProfileUID = uid
        }
        updateServerListMenu()
        
        // Reload the table data when the server preferences window is open.
        if let serverPreferencesWindow = self.serverPreferencesWindow {
            serverPreferencesWindow.serverProfileListTableView.reloadData()
        }
        
        if isRunning {
            restartTrojanProxy()
        }
    }
    
    func startTrojanProxy() {
        if let profile = PreferencePlist.activeServerTrojanProfile, self.runningMode != .off {
            if gererateTrojanConfig(profile) {
                startTrojan()
                ProxyConfHelper.autoProxy()
            }
        }
    }
    
    func stopTrojanProxy() {
        stopTrojan()
        ProxyConfHelper.turnDownProxyMode()
    }
    
    func restartTrojanProxy() {
        stopTrojanProxy()
        startTrojanProxy()
    }
    
    // MARK: - ServerPreferencesWindowDelegate
    func serverPreferenceWindowWillClose(_ window: ServerPreferencesWindow) {
        self.serverPreferencesWindow = nil
    }
    
    // MARK: - PreferencesWindowDelegate
    func PreferencesWindowWillClose(_ window: PreferencesWindow) {
        self.preferencesWindow = nil
    }
    
    // MARK: - UserRulesWindowDelgate
    func userRulesWindowWillClose(sender: UserRulesWindow, notify: Notification) {
        self.editUserRulesWindow = nil
    }
    
    // MARK: - NSMenuDelegate
    func menuWillOpen(_ menu: NSMenu) {
        self.updateServerListMenu()
    }
}

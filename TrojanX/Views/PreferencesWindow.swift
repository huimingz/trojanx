//
//  PreferencesWindow.swift
//  TrojanX
//
//  Created by Sakurai on 2020/01/03.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import Cocoa

class PreferencesWindow: NSWindowController, NSWindowDelegate  {
    
    let default_socks5_addr = "127.0.0.1"
    let default_socks5_port = "1080"
    let default_pac_server_port = "1089"
    let default_tcp_no_dely = true
    let default_tcp_keep_alive = true
    let default_tcp_reuse_port = false
    let default_tcp_fast_open = false
    let default_tcp_fast_open_qlen = "20"
    let default_trojan_log_location = NSHomeDirectory() + "/Library/Logs/trojan.log"
    
    @IBOutlet weak var toolBar: NSToolbar!
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var generalToolBar: NSToolbarItem!
    @IBOutlet weak var advancedToolBar: NSToolbarItem!
    @IBOutlet weak var generalCheckBoxAutoLaunchAtLogin: NSButton!
    @IBOutlet weak var generalCheckBoxHideDockIcon: NSButton!
    @IBOutlet weak var advancedSocks5ListenAddressTextField: NSTextField!
    @IBOutlet weak var advancedSocks5ListenPortTextField: NSTextField!
    @IBOutlet weak var advancedPACServerListenPortTextField: NSTextField!
    @IBOutlet weak var advancedTrojanTCPNoDelayCheckBox: NSButton!
    @IBOutlet weak var advancedTrojanTCPKeepAliveCheckBox: NSButton!
    @IBOutlet weak var advancedTrojanTCPReusePortCheckBox: NSButton!
    @IBOutlet weak var advancedTrojanTCPFastOpenCheckBox: NSButton!
    @IBOutlet weak var advancedTrojanTCPFastOpenQlenTextField: NSTextField!
    @IBOutlet weak var advancedTrojanLogLevelComboBox: NSComboBox!
    @IBOutlet weak var advancedTrojanLogFielLocationTextFiled: NSTextField!
    
    weak var delegate: PreferencesWindowDelegate!

    override func windowDidLoad() {
        // Remember the windows postion and size, will be apply when next open.
        self.window?.setFrameAutosaveName("PreferencesWindow")
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.generalCheckBoxHideDockIcon.state = PreferencePlist.hideDockAppIcon ? NSControl.StateValue.on : NSControl.StateValue.off
        self.toolBar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue:"general")
        self.resetAdvancedFormToBefore()
    }
    
    @IBAction func toolBarAction(_ sender: NSToolbarItem) {
        self.tabView.selectTabViewItem(withIdentifier: sender.itemIdentifier)
    }
    
    // MARK: - General Config Event
    @IBAction func clickHideDockIconCheckBox(_ sender: NSButton) {
        NSLog("check state: \(sender.state)")
        PreferencePlist.hideDockAppIcon = (sender.state == .on) ? true : false
        
        switch sender.state {
        case .on:
            NSApp.setActivationPolicy(.accessory)
        case .off:
            NSApp.setActivationPolicy(.regular)
        default:
            break
        }
    }
    
    // MARK: - General Config Event
    @IBAction func clickAdvancedFastOpenCheckBox(_ sender: NSButton) {
        if sender.state == .on {
            self.advancedTrojanTCPFastOpenQlenTextField.isEnabled = true
        } else if sender.state == .off {
            self.advancedTrojanTCPFastOpenQlenTextField.isEnabled = false
        }
    }
    
    @IBAction func resetAdvancedConfig(_ sender: Any) {
        self.resetAdcancedForm()
    }
    
    @IBAction func applyAdvancedConfig(_ sender: Any) {
        if !validateAdvancedForm() {
            shakeWindow()
            return
        }
        
        PreferencePlist.localSocks5ListenAddr = self.advancedSocks5ListenAddressTextField.stringValue
        PreferencePlist.localSocks5ListenPort = self.advancedSocks5ListenPortTextField.integerValue
        PreferencePlist.pacServerListenPort = self.advancedPACServerListenPortTextField.integerValue
        PreferencePlist.trojanTCPNoDely = self.advancedTrojanTCPNoDelayCheckBox.state == .on
        PreferencePlist.trojanTCPKeepAlive = self.advancedTrojanTCPKeepAliveCheckBox.state == .on
        PreferencePlist.trojanTCPReusePort = self.advancedTrojanTCPReusePortCheckBox.state == .on
        PreferencePlist.trojanTCPFastOpen = self.advancedTrojanTCPFastOpenCheckBox.state == .on
        PreferencePlist.trojanTCPFastOpenQlen = self.advancedTrojanTCPFastOpenQlenTextField.integerValue
        
        let logLevelSelectedIndex = self.advancedTrojanLogLevelComboBox.indexOfSelectedItem
        if let level = PreferencePlist.trojanLogLevel.init(rawValue: logLevelSelectedIndex) {
            PreferencePlist.trojanServiceLogLevel = level.rawValue
        }
    }
    
    // MARK: - NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        if let delegate = self.delegate {
            delegate.PreferencesWindowWillClose?(self)
        }
    }
    
    // MARK: - Custome Method
    func resetAdcancedForm() {
        self.advancedSocks5ListenAddressTextField.stringValue = self.default_socks5_addr
        self.advancedSocks5ListenPortTextField.stringValue = self.default_socks5_port
        self.advancedPACServerListenPortTextField.stringValue = self.default_pac_server_port
        self.advancedTrojanTCPNoDelayCheckBox.state = self.default_tcp_no_dely ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPKeepAliveCheckBox.state = self.default_tcp_keep_alive ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPReusePortCheckBox.state = self.default_tcp_reuse_port ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPFastOpenCheckBox.state = self.default_tcp_fast_open ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPFastOpenQlenTextField.isEnabled = false
        self.advancedTrojanTCPFastOpenQlenTextField.stringValue = String(self.default_tcp_fast_open_qlen)
        self.advancedTrojanLogLevelComboBox.selectItem(at: PreferencePlist.trojanLogLevel.info.rawValue)
        self.advancedTrojanLogFielLocationTextFiled.stringValue = self.default_trojan_log_location
    }
    
    func resetAdvancedFormToBefore() {
        self.advancedSocks5ListenAddressTextField.stringValue = PreferencePlist.localSocks5ListenAddr
        self.advancedSocks5ListenPortTextField.stringValue = String(PreferencePlist.localSocks5ListenPort)
        self.advancedPACServerListenPortTextField.stringValue = String(PreferencePlist.pacServerListenPort)
        self.advancedTrojanTCPNoDelayCheckBox.state = PreferencePlist.trojanTCPNoDely ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPKeepAliveCheckBox.state = PreferencePlist.trojanTCPKeepAlive ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPReusePortCheckBox.state = PreferencePlist.trojanTCPReusePort ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPFastOpenCheckBox.state = PreferencePlist.trojanTCPFastOpen ? NSControl.StateValue.on : NSControl.StateValue.off
        self.advancedTrojanTCPFastOpenQlenTextField.isEnabled = PreferencePlist.trojanTCPFastOpen
        self.advancedTrojanTCPFastOpenQlenTextField.stringValue = String(PreferencePlist.trojanTCPFastOpenQlen)
        self.advancedTrojanLogLevelComboBox.selectItem(at: PreferencePlist.trojanServiceLogLevel)
        self.advancedTrojanLogFielLocationTextFiled.stringValue = self.default_trojan_log_location
    }
    
    func validateAdvancedForm() -> Bool {
        if isValidatedAdvancedSocks5Port() &&
            isValidatedAdcancedSocks5Address() &&
            isValidatedAdvancedPACServerPort() &&
            isValidatedAdvancedLogFiledLocation() &&
            isValidatedAdvancedTrojanTCPFastOpenQlen() {
            return true
        }
        return false
    }
    
    // MARK: - Validate TextField Value
    func isValidatedAdcancedSocks5Address() -> Bool {
        let addr = self.advancedSocks5ListenAddressTextField.stringValue
        
        if addr == "0.0.0.0" || addr == "127.0.0.1" || addr == "localhost" {
            return true
        }
        return false
    }
    
    func isValidatedAdvancedSocks5Port() -> Bool {
        let port = self.advancedSocks5ListenPortTextField.integerValue
        if port > 0 && port < 65535 {
            return true
        }
        return false
    }
    
    func isValidatedAdvancedPACServerPort() -> Bool {
        let pacPort = self.advancedPACServerListenPortTextField.integerValue
        let socPort = self.advancedSocks5ListenPortTextField.integerValue
        
        if pacPort > 0 && pacPort < 65535 && pacPort != socPort {
            return true
        }
        return false
    }
    
    func isValidatedAdvancedTrojanTCPFastOpenQlen() -> Bool {
        let qlen = self.advancedTrojanTCPFastOpenQlenTextField.integerValue
        
        if qlen > 0 {
            return true
        }
        return false
    }
    
    func isValidatedAdvancedLogFiledLocation() -> Bool {
        return true
    }
}


@objc protocol PreferencesWindowDelegate: AnyObject {
    @objc optional func PreferencesWindowWillClose(_ window: PreferencesWindow) -> Void
}

//
//  ServerPreferencesWindow.swift
//  TrojanX
//
//  Created by Sakurai on 2020/01/01.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import Cocoa

class ServerPreferencesWindow: NSWindowController, NSTableViewDataSource, NSTableViewDelegate, NSWindowDelegate {
    // TODO: support shortcut(Commant+V) to paste text to textfiled.
    
    @IBOutlet weak var textFieldRemark: NSTextField!
    @IBOutlet weak var textFieldAddr: NSTextField!
    @IBOutlet weak var textFieldPort: NSTextField!
    @IBOutlet weak var textFieldPassword: NSSecureTextField!
    @IBOutlet weak var textFieldCurves: NSTextField!
    @IBOutlet weak var checkBoxVerifyDomain: NSButton!
    @IBOutlet weak var checkBoxReuseSession: NSButton!
    @IBOutlet weak var checkBoxSessionTicket: NSButton!
    @IBOutlet weak var trojanFormView: NSView!
    @IBOutlet weak var serverProfileListTableView: NSTableView!
    
    var editingProfileUID: String?
    var isAddMode: Bool = false
    var isFirstTableLoad: Bool = false
    let trojanProfilePasteboardType = NSPasteboard.PasteboardType("trojan.service.profile.data")
    
    weak var delegate: ServerPreferencesWindowDelegate?
    
    override func windowDidLoad() {
        // Remember the windows postion and size, will be apply when next open.
        self.window?.setFrameAutosaveName("ServerPreferencesWindow")
        
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.serverProfileListTableView.registerForDraggedTypes([self.trojanProfilePasteboardType])
    }
    
    override func windowWillLoad() {
        
    }
    
    func resetForm() {
        self.editingProfileUID = nil
        self.textFieldRemark.stringValue = self.textFieldRemark.placeholderString ?? ""
        self.textFieldAddr.stringValue = self.textFieldAddr.placeholderString ?? ""
        self.textFieldPort.stringValue = self.textFieldPort.placeholderString ?? ""
        self.textFieldPassword.stringValue = self.textFieldPort.placeholderString ?? ""
        self.textFieldCurves.stringValue = self.textFieldCurves.placeholderString ?? ""
        self.checkBoxReuseSession.state = .on
        self.checkBoxVerifyDomain.state = .off
        self.checkBoxSessionTicket.state = .off
    }
    
    func getTrojanProfileAndVerify() -> [String: Any]? {
        var data = [String: Any]()
        if self.textFieldRemark.stringValue != "" {
            data[PreferencePlist.KEY_TROJAN_PROFILE_REMARK] = self.textFieldRemark.stringValue
        } else {
            return nil
        }
        
        if self.textFieldAddr.stringValue != "" {
            data[PreferencePlist.KEY_TROJAN_PROFILE_SERVER_ADDR] = self.textFieldAddr.stringValue
        } else {
            return nil
        }
        
        if self.textFieldPort.integerValue != 0, self.textFieldPort.integerValue > 0, self.textFieldPort.integerValue < 65535 {
            data[PreferencePlist.KEY_TROJAN_PROFILE_SERVER_PORT] = self.textFieldPort.integerValue
        } else {
            return nil
        }
        
        if self.textFieldPassword.stringValue != "" {
            data[PreferencePlist.KEY_TROJAN_PROFILE_PASSWORD] = self.textFieldPassword.stringValue
        } else {
            return nil
        }
        
        data[PreferencePlist.KEY_TROJAN_PROFILE_CURVES] = self.textFieldCurves.stringValue
        data[PreferencePlist.KEY_TROJAN_PROFILE_VERIFY_DOMAIN] = self.checkBoxVerifyDomain.state == .on
        data[PreferencePlist.KEY_TROJAN_PROFILE_REUSE_SESSION] = self.checkBoxReuseSession.state == .on
        data[PreferencePlist.KEY_TROJAN_PROFILE_SESSION_TICKET] = self.checkBoxSessionTicket.state == .on
        
        if self.editingProfileUID == nil {
            self.editingProfileUID = UUID().uuidString
        }
        data[PreferencePlist.KEY_TROJAN_PROFILE_UID] = self.editingProfileUID!
        return data
    }
    
    @IBAction func addProfile(_ sender: NSButton) {
        resetForm()
        self.editingProfileUID = UUID().uuidString
    }
    
    @IBAction func removeProfile(_ sender: NSButton) {
        // TODO: implement remove row function.
        let selectedRow = self.serverProfileListTableView.selectedRow
        if PreferencePlist.trojanServerProfileList.indices.contains(selectedRow) {
            // remove the selected row from the table with animation.
            self.serverProfileListTableView.beginUpdates()
            self.serverProfileListTableView.removeRows(at: IndexSet(arrayLiteral: selectedRow), withAnimation: .effectFade)
            self.serverProfileListTableView.endUpdates()
            
            // update data to preference plist file.
            var oldProfileList = PreferencePlist.trojanServerProfileList
            oldProfileList.remove(at: selectedRow)
            PreferencePlist.trojanServerProfileList = oldProfileList
        }
    }
    
    @IBAction func resetProfileForm(_ sender: NSButton) {
        // If current form data is from plist file, reset the form data to original.
        let profile = PreferencePlist.trojanServerProfileList.first(where: { $0[PreferencePlist.KEY_TROJAN_PROFILE_UID] as? String == self.editingProfileUID })
        if let profile = profile, let pp = TrojanFullProfile.getProfileFromDict(profile){
            NSLog("Reset form data to original.")
            self.textFieldRemark.stringValue = pp.remark
            self.textFieldAddr.stringValue = pp.remoteAddr
            self.textFieldPort.stringValue = String(pp.remotePort)
            self.textFieldPassword.stringValue = pp.password
            self.textFieldCurves.stringValue = pp.SSLcurves
            self.checkBoxReuseSession.state = pp.SSLReuseSession ? NSControl.StateValue.on : NSControl.StateValue.off
            self.checkBoxVerifyDomain.state = pp.SSLverifyHostName ? NSControl.StateValue.on : NSControl.StateValue.off
            self.checkBoxSessionTicket.state = pp.SSLSessionTicket ? NSControl.StateValue.on : NSControl.StateValue.off
        } else {
            NSLog("Reset form data to empty.")
            self.resetForm()
        }
    }
    
    @IBAction func saveProfile(_ sender: NSButton) {
        if let profile = getTrojanProfileAndVerify() {
            var oldProfileList = PreferencePlist.trojanServerProfileList
            oldProfileList.addTrojanProfile(profile)
            PreferencePlist.trojanServerProfileList = oldProfileList
            self.serverProfileListTableView.reloadData()
        } else {
            shakeWindow()
        }
    }
    
    // MARK: - NSWindowDele Method
    func windowWillClose(_ notification: Notification) {
        if let delegate = self.delegate {
            delegate.serverPreferenceWindowWillClose?(self)
        }
    }
    
    // MARK: - NSTableViewDataSource Method
    func numberOfRows(in tableView: NSTableView) -> Int {
        return PreferencePlist.trojanServerProfileList.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if PreferencePlist.trojanServerProfileList.indices.contains(row) {
            let profile = PreferencePlist.trojanServerProfileList[row]
            
            // icon column
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("status") {
                
                if let uid = profile[PreferencePlist.KEY_TROJAN_PROFILE_UID], let suid = uid as? String, suid == PreferencePlist.activeServerProfileUID {
                    // set the selected row to form
                    if !self.isFirstTableLoad, let p = TrojanFullProfile.getProfileFromDict(profile) {
                        self.editingProfileUID = p.uid
                        self.textFieldRemark.stringValue = p.remark
                        self.textFieldAddr.stringValue = p.remoteAddr
                        self.textFieldPort.integerValue = p.remotePort
                        self.textFieldPassword.stringValue = p.password
                        self.textFieldCurves.stringValue = p.SSLcurves
                        self.checkBoxSessionTicket.state = p.SSLSessionTicket ? NSControl.StateValue.on : NSControl.StateValue.off
                        self.checkBoxVerifyDomain.state = p.SSLverifyHostName ? NSControl.StateValue.on : NSControl.StateValue.off
                        self.checkBoxReuseSession.state = p.SSLReuseSession ? NSControl.StateValue.on : NSControl.StateValue.off
                        self.isFirstTableLoad = true
                    }
                    return NSImage(named: NSImage.menuOnStateTemplateName)
                } else {
                    return nil
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("remark") {
                // remark
                if let name = profile[PreferencePlist.KEY_TROJAN_PROFILE_REMARK], let sname = name as? String {
                    return sname
                } else {
                    return "Unknow"
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Allow Drag Operation
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        pbItem.setString(String(row), forType: self.trojanProfilePasteboardType)
        return pbItem
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard.pasteboardItems?.first,
            let theString = item.string(forType: self.trojanProfilePasteboardType),
            let sourceRow = Int(theString)
            else { return false }
        
        // Check the sourceRow(idx) is valid.
        if !PreferencePlist.trojanServerProfileList.indices.contains(sourceRow) {
            return false
        }
        
        // When you drag an item downwards, the "new row" index is actually --1.
        var destRow = row
        if sourceRow < row {
            destRow = row - 1
        }
        
        // Animate for the rows.
        self.serverProfileListTableView.beginUpdates()
        self.serverProfileListTableView.moveRow(at: sourceRow, to: destRow)
        self.serverProfileListTableView.endUpdates()
        
        // Update profile data list to the plist model.
        var oldProfileList = PreferencePlist.trojanServerProfileList
        let profile = oldProfileList.remove(at: sourceRow)
        oldProfileList.insert(profile, at: destRow)
        PreferencePlist.trojanServerProfileList = oldProfileList
        
        return true
    }
    
    // MARK: - NSTableViewDelegate Method
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let dict = PreferencePlist.trojanServerProfileList[row]
        let profile = TrojanFullProfile.getProfileFromDict(dict)
        if let p = profile {
            self.editingProfileUID = p.uid
            self.textFieldRemark.stringValue = p.remark
            self.textFieldAddr.stringValue = p.remoteAddr
            self.textFieldPort.stringValue = String(p.remotePort)
            self.textFieldCurves.stringValue = p.SSLcurves
            self.textFieldPassword.stringValue = p.password
            self.checkBoxReuseSession.state = p.SSLReuseSession ? NSControl.StateValue.on : NSControl.StateValue.off
            self.checkBoxVerifyDomain.state = p.SSLverifyHostName ? NSControl.StateValue.on : NSControl.StateValue.off
            self.checkBoxSessionTicket.state = p.SSLSessionTicket ? NSControl.StateValue.on : NSControl.StateValue.off
            return true
        }
        return false
    }
}


@objc protocol ServerPreferencesWindowDelegate: AnyObject {
    
    @objc optional func serverPreferenceWindowWillClose(_ window: ServerPreferencesWindow) -> Void
}

fileprivate extension Array {
    mutating func addTrojanProfile(_ profile: [String: Any]) {
        if let newUIDAnyType = profile[PreferencePlist.KEY_TROJAN_PROFILE_UID], let newUID = newUIDAnyType as? String  {
            var isExists = false
            for (idx, item) in self.enumerated() {
                if let dict = item as? [String: Any], let currUIDAnyType = dict[PreferencePlist.KEY_TROJAN_PROFILE_UID], let currUID = currUIDAnyType as? String, currUID == newUID {
                    isExists = true
                    self[idx] = profile as! Element
                }
            }
            
            if !isExists {
                self.append(profile as! Element)
            }
        }
    }
}

//
//  UserRulesWindow.swift
//  TrojanX
//
//  Created by Sakurai on 2020/1/6.
//  Copyright © 2020 Sakurai. All rights reserved.
//

import Cocoa

class UserRulesWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet var userRulesTextField: NSTextView!
    
    weak var delegate: UserRulesWindowDelgate?
    var userRulesMd5_Old: String = ""
    
    override func windowDidLoad() {
        self.shouldCascadeWindows = false
        self.window?.setFrameAutosaveName("UserRulesWindow")
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        if !FileManager.default.fileExists(atPath: PACUserRuleFilePath) {
            let src = Bundle.main.path(forResource: "user-rule", ofType: "txt")
            try! FileManager.default.copyItem(atPath: src!, toPath: PACUserRuleFilePath)
        }
        
        if let context = try? String(contentsOfFile: PACUserRuleFilePath, encoding: .utf8) {
            self.userRulesTextField.string = context
            self.userRulesMd5_Old = context.md5()
        }
    }
    
    func windowWillClose(_ notification: Notification) {
        if let delegate = self.delegate {
            delegate.userRulesWindowWillClose?(sender: self, notify: notification)
        }
    }
    
    @IBAction func clickConfirmButton(_ sender: NSButton) {
        let content = self.userRulesTextField.string
        
        // Check for context hash(md5) changes
        let userRulesMd5_new = content.md5()
        if userRulesMd5_Old != userRulesMd5_new {
            do {
                // Save content to file.
                try content.write(to: URL(fileURLWithPath: PACUserRuleFilePath), atomically: true, encoding: .utf8)
                self.userRulesMd5_Old = userRulesMd5_new
                
                let notify = NSUserNotification()
                notify.title = "Success".localized
                notify.informativeText = "Save content to file.".localized
                notify.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notify)
                self.window?.performClose(self)
            } catch {
                let notify = NSUserNotification()
                notify.title = "failed".localized
                notify.informativeText = "Can't save content to file, message: \(error).".localized
                notify.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notify)
            }
        }
    }
    
    @IBAction func clickCancelButton(_ sender: NSButton) {
        self.window?.performClose(self)
    }
}

@objc protocol UserRulesWindowDelgate: AnyObject {
    @objc optional func userRulesWindowWillClose(sender: UserRulesWindow, notify: Notification) -> Void;
}

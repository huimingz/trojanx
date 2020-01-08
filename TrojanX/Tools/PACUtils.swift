//
//  PACUtils.swift
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 16/6/9.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

import Foundation
//import Alamofire

let OldErrorPACRulesDirPath = NSHomeDirectory() + "/.ShadowsocksX-NE/"

let PACRulesDirPath = NSHomeDirectory() + "/.TrojanX/"
let PACUserRuleFilePath = PACRulesDirPath + "user-rule.txt"
let PACFilePath = PACRulesDirPath + "gfwlist.js"
let GFWListFilePath = PACRulesDirPath + "gfwlist.txt"


// Because of LocalSocks5.ListenPort may be changed
func SyncPac() {
    var needGenerate = false
    
//    let nowSocks5Address = UserDefaults.standard.string(forKey: "LocalSocks5.ListenAddress")
//    let oldSocks5Address = UserDefaults.standard.string(forKey: "LocalSocks5.ListenAddress.Old")
//    if nowSocks5Address != oldSocks5Address {
//        needGenerate = true
//        UserDefaults.standard.set(nowSocks5Address, forKey: "LocalSocks5.ListenAddress.Old")
//    }
//
//    let nowSocks5Port = UserDefaults.standard.integer(forKey: "LocalSocks5.ListenPort")
//    let oldSocks5Port = UserDefaults.standard.integer(forKey: "LocalSocks5.ListenPort.Old")
//    if nowSocks5Port != oldSocks5Port {
//        needGenerate = true
//        UserDefaults.standard.set(nowSocks5Port, forKey: "LocalSocks5.ListenPort.Old")
//    }
    
    if PreferencePlist.localSocks5ListenAddr != PreferencePlist.localSocks5ListenAddrOld {
        needGenerate = true
        PreferencePlist.localSocks5ListenAddrOld = PreferencePlist.localSocks5ListenAddr
    }
    
    if PreferencePlist.localSocks5ListenPort != PreferencePlist.localSocks5ListenPortOld {
        needGenerate = true
        PreferencePlist.localSocks5ListenPortOld = PreferencePlist.localSocks5ListenPort
    }
    
    let fileMgr = FileManager.default
    // Check the PAC file.
    if !fileMgr.fileExists(atPath: PACFilePath) {
        needGenerate = true
    }
    
    // Check the user rule file.
    if !fileMgr.fileExists(atPath: PACUserRuleFilePath) {
        needGenerate = true
    } else {
        let fileSha1Sum = getFileSha1Sum(PACUserRuleFilePath)
        if fileSha1Sum != PreferencePlist.usrRuleFileSha1Sum {
            needGenerate = true
        }
    }
    
    // Check the gfwlist file.
    if !fileMgr.fileExists(atPath: GFWListFilePath) {
        needGenerate = true
    } else {
        let fileSha1Sum = getFileSha1Sum(GFWListFilePath)
        if fileSha1Sum != PreferencePlist.gfwListFileSha1Sum {
            needGenerate = true
        }
    }
    
    if needGenerate {
        if !GeneratePACFile() {
            NSLog("GeneratePACFile failed!")
        }
    }
}


func GeneratePACFile() -> Bool {
    let fileMgr = FileManager.default
    
    // Maker the dir if rulesDirPath is not exesited.
    if !fileMgr.fileExists(atPath: PACRulesDirPath) {
        try! fileMgr.createDirectory(atPath: PACRulesDirPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    // If gfwlist.txt is not exsited, copy from bundle
    if !fileMgr.fileExists(atPath: GFWListFilePath) {
        let src = Bundle.main.path(forResource: "gfwlist", ofType: "txt")
        try! fileMgr.copyItem(atPath: src!, toPath: GFWListFilePath)
    }
    
    // If user-rule.txt is not exsited, copy from bundle
    if !fileMgr.fileExists(atPath: PACUserRuleFilePath) {
        let src = Bundle.main.path(forResource: "user-rule", ofType: "txt")
        try! fileMgr.copyItem(atPath: src!, toPath: PACUserRuleFilePath)
    }
    
    // Set the sha1sum of new file sha1 value to plist file.
    PreferencePlist.gfwListFileSha1Sum = getFileSha1Sum(GFWListFilePath)
    PreferencePlist.usrRuleFileSha1Sum = getFileSha1Sum(PACUserRuleFilePath)
    
    let socks5Address = PreferencePlist.localSocks5ListenAddr
    let socks5Port = PreferencePlist.localSocks5ListenPort
    
    do {
        let gfwlist = try String(contentsOfFile: GFWListFilePath, encoding: String.Encoding.utf8)
        if let data = Data(base64Encoded: gfwlist, options: .ignoreUnknownCharacters) {
            let str = String(data: data, encoding: String.Encoding.utf8)
            var lines = str!.components(separatedBy: CharacterSet.newlines)
            
            do {
                let userRuleStr = try String(contentsOfFile: PACUserRuleFilePath, encoding: String.Encoding.utf8)
                let userRuleLines = userRuleStr.components(separatedBy: CharacterSet.newlines)
                
                lines = userRuleLines + lines
            } catch {
                NSLog("Not found user-rule.txt")
            }
            
            // Filter empty and comment lines
            lines = lines.filter({ (s: String) -> Bool in
                if s.isEmpty {
                    return false
                }
                let c = s[s.startIndex]
                if c == "!" || c == "[" {
                    return false
                }
                return true
            })
            
            do {
                // rule lines to json array
                let rulesJsonData: Data
                    = try JSONSerialization.data(withJSONObject: lines, options: .prettyPrinted)
                let rulesJsonStr = String(data: rulesJsonData, encoding: String.Encoding.utf8)
                
                // Get raw pac js
                let jsPath = Bundle.main.url(forResource: "abp", withExtension: "js")
                let jsData = try? Data(contentsOf: jsPath!)
                var jsStr = String(data: jsData!, encoding: String.Encoding.utf8)
                
                // Replace rules placeholder in pac js
                jsStr = jsStr!.replacingOccurrences(of: "__RULES__"
                    , with: rulesJsonStr!)
                // Replace __SOCKS5PORT__ palcholder in pac js
                jsStr = jsStr!.replacingOccurrences(of: "__SOCKS5PORT__"
                    , with: "\(socks5Port)")
                // Replace __SOCKS5ADDR__ palcholder in pac js
                var sin6 = sockaddr_in6()
                if socks5Address.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
                    jsStr = jsStr!.replacingOccurrences(of: "__SOCKS5ADDR__"
                        , with: "[\(socks5Address)]")
                } else {
                    jsStr = jsStr!.replacingOccurrences(of: "__SOCKS5ADDR__"
                        , with: socks5Address)
                }
                
                // Write the pac js to file.
                try jsStr!.data(using: String.Encoding.utf8)?
                    .write(to: URL(fileURLWithPath: PACFilePath), options: .atomic)
                
                return true
            } catch {
                
            }
        }
        
    } catch {
        NSLog("Not found gfwlist.txt")
    }
    return false
}

//func UpdatePACFromGFWList() {
//    // Make the dir if rulesDirPath is not exesited.
//    if !FileManager.default.fileExists(atPath: PACRulesDirPath) {
//        do {
//            try FileManager.default.createDirectory(atPath: PACRulesDirPath
//                , withIntermediateDirectories: true, attributes: nil)
//        } catch {
//        }
//    }
//
//    let url = UserDefaults.standard.string(forKey: "GFWListURL")
//    Alamofire.request(url!)
//        .responseString {
//            response in
//            if response.result.isSuccess {
//                if let v = response.result.value {
//                    do {
//                        try v.write(toFile: GFWListFilePath, atomically: true, encoding: String.Encoding.utf8)
//                        if GeneratePACFile() {
//                            // Popup a user notification
//                            let notification = NSUserNotification()
//                            notification.title = "PAC has been updated by latest GFW List."
//                            NSUserNotificationCenter.default
//                                .deliver(notification)
//                        }
//                    } catch {
//
//                    }
//                }
//            } else {
//                // Popup a user notification
//                let notification = NSUserNotification()
//                notification.title = "Failed to download latest GFW List."
//                NSUserNotificationCenter.default
//                    .deliver(notification)
//            }
//        }
//}

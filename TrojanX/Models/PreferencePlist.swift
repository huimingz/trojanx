//
//  PreferencesPlistManager.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/31.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Foundation


let DEFAULT_PAC_URL = "https://raw.githubusercontent.com/petronny/gfwlist2pac/master/gfwlist.pac"

class PreferencePlist {
    
    enum trojanLogLevel: Int {
        case all = 0, info = 1, warn = 2, error = 3, fatal = 4, off = 5
        
        var description: String {
            switch self {
            case .all:
                return "ALL"
            case .info:
                return "INFO"
            case .warn:
                return "WARN"
            case .error:
                return "ERROR"
            case .fatal:
                return "FATAL"
            case .off:
                return "OFF"
            }
        }
        
        func string2enum(_ str: String) -> trojanLogLevel? {
            switch str {
            case "ALL", "All", "all":
                return trojanLogLevel.all
            case "INFO", "Info", "info":
                return trojanLogLevel.info
            case "WARN", "Warn", "warn":
                return trojanLogLevel.warn
            default:
                return nil
            }
        }
    }
    
    static let KEY_TROJAN_SERVER_PROFILE_LIST: String = "TrojanServerProfileList"
    static let KEY_TROJAN_PROFILE_UID: String = "UID"
    static let KEY_TROJAN_PROFILE_REMARK: String = "Remark"
    static let KEY_TROJAN_PROFILE_SERVER_ADDR: String = "RemoteAddr"
    static let KEY_TROJAN_PROFILE_SERVER_PORT: String = "RemotePort"
    static let KEY_TROJAN_PROFILE_PASSWORD: String = "Password"
    static let KEY_TROJAN_PROFILE_VERIFY_DOMAIN: String = "VerifyDomain"
    static let KEY_TROJAN_PROFILE_REUSE_SESSION: String = "ReuseSession"
    static let KEY_TROJAN_PROFILE_SESSION_TICKET: String = "SessionTiket"
    static let KEY_TROJAN_PROFILE_CURVES: String = "Curves"
    
    static let KEY_RUNNING_MODE: String = "TrojanXRunningMode"
    static let KEY_HIDE_DOCK_APP_ICON: String = "HideDockIcon"
    static let KEY_AUTO_PAC_FILE_URL: String = "AutoPACFileURL"  // deprecated
    static let KEY_ACTIVE_SERVER_PROFILE_UID: String = "ActiveServerProfileUID"
    static let KEY_TROJAN_SERVICE_PID: String = "TrojanService.PID"
    static let KEY_TROJAN_SOCKS5_LISTEN_PORT: String = "LocalSocks5.ListenPort"
    static let KEY_TROJAN_SOCKS5_LISTEN_ADDR: String = "LocalSocks5.ListenAddr"
    static let KEY_TROJAN_SOCKS5_LISTEN_PORT_OLD: String = "LocalSocks5.ListenPort.Old"
    static let KEY_TROJAN_SOCKS5_LISTEN_ADDR_ODL: String = "LocalSocks5.ListenAddr.Old"
    static let KEY_PAC_SERVER_LISTEN_ADDR: String = "PacServer.ListenAddr"
    static let KEY_PAC_SERVER_LISTEN_PORT: String = "PacServer.ListenPort"
    static let KEY_TROJAN_TCP_KEEP_ALIVE: String = "Trojan.TCP.KeepAlive"
    static let KEY_TROJAN_TCP_REUSE_PORT: String = "Trojan.TCP.ReusePort"
    static let KEY_TROJAN_TCP_NO_DELY: String = "Trojan.TCP.NoDely"
    static let KEY_TROJAN_TCP_FAST_OPEN: String = "Trojan.TCP.FastOpen"
    static let KEY_TROJAN_TCP_FAST_OPEN_QLEN: String = "Trojan.TCP.FastOpenQlen"
    static let KEY_TROJAN_LOG_LEVEL: String = "Trojan.LogLevel"
    static let KEY_TROJAN_GFW_LIST_FILE_SHA1: String = "TrojanX.GFWListFile.Sha1Sum"
    static let KEY_TROJAN_USR_RULE_File_SHA1: String = "TrojanX.UsrRuleFile.Sha1Sum"
    
    static var resetToDefaultValue: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "ResetToDefaultValue")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "ResetToDefaultValue")
        }
    }
    
    // If the key not in plist file, will return false
    static var hideDockAppIcon: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.KEY_HIDE_DOCK_APP_ICON)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_HIDE_DOCK_APP_ICON)
        }
    }
    
    static var trojanServicePID: Int {
        get {
            return UserDefaults.standard.integer(forKey: self.KEY_TROJAN_SERVICE_PID)
        }
            
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SERVICE_PID)
        }
    }
    
    static var localSocks5ListenPort: Int {
        get {
            let port = UserDefaults.standard.integer(forKey: self.KEY_TROJAN_SOCKS5_LISTEN_PORT)
            if port != 0 {
                return port
            } else {
                UserDefaults.standard.set(1080, forKey: self.KEY_TROJAN_SOCKS5_LISTEN_PORT)
                return 1080
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SOCKS5_LISTEN_PORT)
        }
    }
    
    static var localSocks5ListenPortOld: Int {
        get {
            return UserDefaults.standard.integer(forKey: self.KEY_TROJAN_SOCKS5_LISTEN_PORT_OLD)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SOCKS5_LISTEN_PORT_OLD)
        }
    }
    
    static var localSocks5ListenAddr: String {
        get {
            if let addr = UserDefaults.standard.string(forKey: self.KEY_TROJAN_SOCKS5_LISTEN_ADDR) {
                return addr
            } else {
                UserDefaults.standard.set("127.0.0.1", forKey: self.KEY_TROJAN_SOCKS5_LISTEN_ADDR)
                return "127.0.0.1"
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SOCKS5_LISTEN_ADDR)
        }
    }
    
    static var localSocks5ListenAddrOld: String {
        get {
            if let addr =  UserDefaults.standard.string(forKey: self.KEY_TROJAN_SOCKS5_LISTEN_ADDR_ODL) {
                return addr
            } else {
                return ""
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SOCKS5_LISTEN_ADDR_ODL)
        }
    }
    
    static var pacServerListenHost: String {
        get {
            if let host = UserDefaults.standard.string(forKey: self.KEY_PAC_SERVER_LISTEN_ADDR) {
                return host
            } else {
                return "127.0.0.1"
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_PAC_SERVER_LISTEN_ADDR)
        }
    }
    
    static var pacServerListenPort: Int {
        get {
            let port = UserDefaults.standard.integer(forKey: self.KEY_PAC_SERVER_LISTEN_PORT)
            if port != 0 {
                return port
            } else {
                return 1089
            }
        }
        
        set {
            if newValue > 0 && newValue < 65535 {
                UserDefaults.standard.set(newValue, forKey: self.KEY_PAC_SERVER_LISTEN_PORT)
            }
        }
    }
    
    static var trojanTCPKeepAlive: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.KEY_TROJAN_TCP_KEEP_ALIVE)
        } set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_TCP_KEEP_ALIVE)
        }
    }
    
    static var trojanTCPReusePort: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.KEY_TROJAN_TCP_REUSE_PORT)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: KEY_TROJAN_TCP_REUSE_PORT)
        }
    }
    
    static var trojanTCPNoDely: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.KEY_TROJAN_TCP_NO_DELY)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_TCP_NO_DELY)
        }
    }
    
    static var trojanTCPFastOpen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: self.KEY_TROJAN_TCP_FAST_OPEN)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_TCP_FAST_OPEN)
        }
    }
    
    static var trojanTCPFastOpenQlen: Int {
        get {
            return UserDefaults.standard.integer(forKey: self.KEY_TROJAN_TCP_FAST_OPEN_QLEN)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_TCP_FAST_OPEN_QLEN)
        }
    }
    
    static var trojanServiceLogLevel: Int {
        get {
            let level = UserDefaults.standard.integer(forKey: self.KEY_TROJAN_LOG_LEVEL)
            if let level = trojanLogLevel.init(rawValue: level) {
                return level.rawValue
            }
            return trojanLogLevel.info.rawValue
        }
        
        set {
            if let level = trojanLogLevel.init(rawValue: newValue) {
                UserDefaults.standard.set(level.rawValue, forKey: self.KEY_TROJAN_LOG_LEVEL)
            }
        }
    }
    
    static var trojanRunningMode: ProxyConfHelper.Mode {
        get {
            if let s = UserDefaults.standard.string(forKey: self.KEY_RUNNING_MODE), let mode = ProxyConfHelper.Mode(rawValue: s) {
                return mode
            } else {
                UserDefaults.standard.set(ProxyConfHelper.Mode.auto.rawValue, forKey: self.KEY_RUNNING_MODE)
                return ProxyConfHelper.Mode.auto
            }
        }
        
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: self.KEY_RUNNING_MODE)
        }
    }
    
    private static var activeServerProfileUIDCache: String?
    static var activeServerProfileUID: String {
        get {
            if self.activeServerProfileUIDCache != nil {
                return activeServerProfileUIDCache!
            }
            
            if let uid = UserDefaults.standard.string(forKey: self.KEY_ACTIVE_SERVER_PROFILE_UID) {
                activeServerProfileUIDCache = uid
                return uid
            } else {
                return ""
            }
        }
        
        set {
            self.activeServerProfileUIDCache = newValue
            UserDefaults.standard.set(newValue, forKey: self.KEY_ACTIVE_SERVER_PROFILE_UID)
        }
    }
    
    private static var trojanServerProfileListCache: [[String: Any]]?
    static var trojanServerProfileList: [[String: Any]] {
        get {
            if self.trojanServerProfileListCache != nil {
                return self.trojanServerProfileListCache!
            }
            
            if let list = UserDefaults.standard.array(forKey: self.KEY_TROJAN_SERVER_PROFILE_LIST), let dictList = list as? [[String: Any]] {
                self.trojanServerProfileListCache = dictList
                return dictList
            }
            return [[String: Any]]()
        }
        
        set {
            self.trojanServerProfileListCache = newValue
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_SERVER_PROFILE_LIST)
        }
    }
    
    static var activeServerTrojanProfile: TrojanFullProfile? {
        get {
            for item in trojanServerProfileList {
                if let u = item[KEY_TROJAN_PROFILE_UID], let uid = u as? String, uid == activeServerProfileUID {
                    return TrojanFullProfile.getProfileFromDict(item)
                }
            }
            
            return nil
        }
    }
    
    static var autoPACFileURL: String {
        get {
            if let url = UserDefaults.standard.string(forKey: self.KEY_AUTO_PAC_FILE_URL), url != "" {
                return url
            } else {
                return DEFAULT_PAC_URL
            }
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_AUTO_PAC_FILE_URL)
        }
    }
    
    static var usrRuleFileSha1Sum: String {
        get {
            if let sha1Sum = UserDefaults.standard.string(forKey: self.KEY_TROJAN_USR_RULE_File_SHA1) {
                return sha1Sum
            }
            return ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_USR_RULE_File_SHA1)
        }
    }
    
    static var gfwListFileSha1Sum: String {
        get {
            if let sha1Sum = UserDefaults.standard.string(forKey: self.KEY_TROJAN_GFW_LIST_FILE_SHA1) {
                return sha1Sum
            }
            return ""
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: self.KEY_TROJAN_GFW_LIST_FILE_SHA1)
        }
    }
}

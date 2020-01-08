//
//  TrojanProfile.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/31.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Foundation


enum ProfileError: Error {
    case invalidDictData
}


class TrojanProfile {
    var uid: String
    
    var remotePort: Int
    var remoteAddr: String
    var password: String
    var SSLverifyHostName: Bool = false
    var SSLReuseSession: Bool = true
    var SSLSessionTicket: Bool = false
    var SSLcurves: String = ""
    
    init(remoteAddr: String, remotePort: Int, password: String, uid: String = "") {
        self.remoteAddr = remoteAddr
        self.remotePort = remotePort
        self.password = password
        
        if uid != "" {
            self.uid = uid
        } else {
            self.uid = UUID().uuidString
        }
    }
    
    func toDict() -> [String: Any] {
        var data = [String: Any]()
        data["UID"] = self.uid
        data["RemoteAddre"] = self.remoteAddr
        data["RemotePort"] = self.remotePort
        data["Password"] = self.password
        data["SSL.VerifyDomain"] = self.SSLverifyHostName
        data["SSL.ReuseSession"] = self.SSLReuseSession
        data["SSL.SessionTicket"] = self.SSLSessionTicket
        data["SSL.Curves"] = self.SSLcurves
        return data
    }
}

class TrojanFullProfile: TrojanProfile {
    private var data: [String: Any] = [
        "run_type": "client",
        "local_addr": "127.0.0.1",
        "local_port": 1080,
        "remote_addr": "example.com",
        "remote_port": 443,
        "password": [
            "password1"
        ],
        "log_level": 1,
        "ssl": [
            "verify": false,
            "verify_hostname": true,
            "cert": "",
            "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:RSA-AES128-GCM-SHA256:RSA-AES256-GCM-SHA384:RSA-AES128-SHA:RSA-AES256-SHA:RSA-3DES-EDE-SHA",
            "cipher_tls13":"TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384",
            "sni": "",
            "alpn": [
                "h2",
                "http/1.1"
            ],
            "reuse_session": true,
            "session_ticket": false,
            "curves": ""
        ],
        "tcp": [
            "no_delay": true,
            "keep_alive": true,
            "reuse_port": false,
            "fast_open": false,
            "fast_open_qlen": 20
        ]
    ]
    
    var remark: String = ""
    
    var localPort: Int = 1080
    var localAddr: String = "127.0.0.1"
    
    var logLevel: Int = 1
    
    var TCPNoDelay: Bool = true
    var TCPKeepAlive: Bool = true
    var TCPReusePort: Bool = false
    var TCPFastOpen: Bool = false
    var TCPFastOpenQlen: Int = 20
    
    override init(remoteAddr: String, remotePort: Int, password: String, uid: String = "") {
        super.init(remoteAddr: remoteAddr, remotePort: remotePort, password: password, uid: uid)
    }
    
    override func toDict() -> [String : Any] {
        //        self.data["local_addr"] = self.localAddr
        //        self.data["local_port"] = self.localPort
        self.data["local_addr"] = PreferencePlist.localSocks5ListenAddr
        self.data["local_port"] = PreferencePlist.localSocks5ListenPort
        self.data["remote_addr"] = self.remoteAddr
        self.data["remote_port"] = self.remotePort
        self.data["password"] = [self.password]
        self.data["log_level"] = PreferencePlist.trojanServiceLogLevel
        
        var sslData = self.data["ssl"] as! Dictionary<String, Any>
        sslData["verify_hostname"] = self.SSLverifyHostName
        sslData["reuse_session"] = self.SSLReuseSession
        sslData["session_ticket"] = self.SSLSessionTicket
        sslData["curves"] = self.SSLcurves
        self.data["ssl"] = sslData
        
        var tcpData = self.data["tcp"] as! Dictionary<String, Any>
        //        tcpData["no_delay"] = self.TCPNoDelay
        //        tcpData["keep_alive"] = self.TCPKeepAlive
        //        tcpData["reuse_port"] = self.TCPReusePort
        //        tcpData["fast_open"] = self.TCPFastOpen
        //        tcpData["fast_open_qlen"] = self.TCPFastOpenQlen
        tcpData["no_delay"] = PreferencePlist.trojanTCPNoDely
        tcpData["keep_alive"] = PreferencePlist.trojanTCPKeepAlive
        tcpData["reuse_port"] = PreferencePlist.trojanTCPReusePort
        tcpData["fast_open"] = PreferencePlist.trojanTCPFastOpen
        tcpData["fast_open_qlen"] = PreferencePlist.trojanTCPFastOpenQlen
        self.data["tcp"] = tcpData
        
        return self.data
    }
    
    func writeToFile(filepath: String) -> Bool {
        do {
            let confData = self.toDict()
            let jsonData: Data = try JSONSerialization.data(withJSONObject: confData, options: .prettyPrinted)
            
            var s = String(data: jsonData, encoding: .utf8)!
            s = s.replacingOccurrences(of: "\\/", with: "/")
            
            try s.write(toFile: filepath, atomically: true, encoding: .utf8)
            
            NSLog("write trojan config file successful, location \(filepath)")
            return true
        } catch {
            NSLog("write trojan config file faile, location \(filepath)")
            return false
        }
    }
    
    static func getProfileFromDict(_ dict: [String: Any]) -> TrojanFullProfile? {
        
        var serverAddr: String
        var serverPort: Int
        var password: String
        var verify_domain: Bool
        var reuse_session: Bool
        var session_ticket: Bool
        var curves: String
        var uid: String
        var remark: String
        
        if let addr = dict[PreferencePlist.KEY_TROJAN_PROFILE_SERVER_ADDR], let saddr = addr as? String, !saddr.isEmpty {
            serverAddr = saddr
        } else {
            return nil
        }
        
        if let port = dict[PreferencePlist.KEY_TROJAN_PROFILE_SERVER_PORT], let iport = port as? Int, iport < 65535, iport > 0 {
            serverPort = iport
        } else {
            return nil
        }
        
        if let pwd = dict[PreferencePlist.KEY_TROJAN_PROFILE_PASSWORD], let spwd = pwd as? String, !spwd.isEmpty {
            password = spwd
        } else {
            return nil
        }
        
        if let vd = dict[PreferencePlist.KEY_TROJAN_PROFILE_VERIFY_DOMAIN], let bvd = vd as? Bool {
            verify_domain = bvd
        } else {
            return nil
        }
        
        if let rs = dict[PreferencePlist.KEY_TROJAN_PROFILE_REUSE_SESSION], let brs = rs as? Bool {
            reuse_session = brs
        } else {
            return nil
        }
        
        if let st = dict[PreferencePlist.KEY_TROJAN_PROFILE_SESSION_TICKET], let bst = st as? Bool {
            session_ticket = bst
        } else {
            return nil
        }
        
        if let c = dict[PreferencePlist.KEY_TROJAN_PROFILE_CURVES], let ss = c as? String {
            curves = ss
        } else {
            return nil
        }
        
        if let u = dict[PreferencePlist.KEY_TROJAN_PROFILE_UID], let su = u as? String {
            uid = su
        } else {
            return nil
        }
        
        if let r = dict[PreferencePlist.KEY_TROJAN_PROFILE_REMARK], let sr = r as? String {
            remark = sr
        } else {
            return nil
        }
        
        
        
        let profile = TrojanFullProfile(remoteAddr: serverAddr, remotePort: serverPort, password: password)
        profile.SSLcurves = curves
        profile.SSLReuseSession = reuse_session
        profile.SSLSessionTicket = session_ticket
        profile.SSLverifyHostName = verify_domain
        profile.uid = uid
        profile.remark = remark
        return profile
    }
}


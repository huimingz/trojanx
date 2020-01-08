//
//  ProxyConfHelper.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/31.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Foundation
import GCDWebServer


private let PAC_ROUTE_PATH = "/proxy.pac"

class ProxyConfHelper {
    enum Mode: String {
        case off = "off", global = "global", auto = "auto"
    }
    
    static var proxy_helper_path: String {
        return "/Library/Application Support/" + Bundle.appName() + "/proxy_conf_helper"
    }
    
    static var pacWebServer: GCDWebServer!
    
    static func turnDownProxyMode() {
        stopPACWebServer()
        
        let task = Process()
        task.launchPath = self.proxy_helper_path
        task.arguments = ["-m", self.Mode.off.rawValue]
        task.launch()
        task.waitUntilExit()
    }
    
    static func pacAutoMode(pacUrl: String) {
        let task = Process()
        task.launchPath = self.proxy_helper_path
        task.arguments = ["-m", self.Mode.auto.rawValue, "-u", pacUrl]
        task.launch()
        task.waitUntilExit()
    }
    
    static func socks5GlobalMode() {
        self.turnDownProxyMode()
        
        let port = PreferencePlist.localSocks5ListenPort
        let addr = PreferencePlist.localSocks5ListenAddr
        
        let task = Process()
        task.launchPath = self.proxy_helper_path
        task.arguments = ["-m", self.Mode.global.rawValue, "-p", String(port), "-l", addr]
        task.launch()
        task.waitUntilExit()
    }
    
    static func autoProxy() {
        switch PreferencePlist.trojanRunningMode {
        case .auto:
            // TODO(huimingz): 使用自建服务器来提供pac文件
            // start pac web server.
            SyncPac()
            stopPACWebServer()
            startPACWebServer()
            
            let port = PreferencePlist.pacServerListenPort
            pacAutoMode(pacUrl: "http://127.0.0.1:\(port)\(PAC_ROUTE_PATH)")
        case .global:
            stopPACWebServer()
            socks5GlobalMode()
        case .off: break
        }
    }
    
    static func install() {
        if !FileManager.default.fileExists(atPath: self.proxy_helper_path) {
            let installerPath = Bundle.main.path(forResource: "install_proxy_conf_helper.sh", ofType: nil)!
            NSLog("run install script: \(installerPath)")
            
            let scriptCmd = "do shell script \"/bin/bash \\\"\(installerPath)\\\"\" with administrator privileges"
            let appleScript = NSAppleScript(source: scriptCmd)
            var err: NSDictionary?
            appleScript?.executeAndReturnError(&err)
            
            if err != nil {
                NSLog("installation failure: \(err!)")
            } else {
                NSLog("installation successful")
            }
        }
    }
    
    static func startPACWebServer() -> Void {
        let pacFilePath = PACFilePath
        let pacData = try? Data.init(contentsOf: URL(fileURLWithPath: pacFilePath))
        let webServer = GCDWebServer.init()
        
        webServer.addHandler(forMethod: "GET", path: PAC_ROUTE_PATH, request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            let resp = GCDWebServerDataResponse(data: pacData!, contentType: "application/x-ns-proxy-autoconfig")
            return resp
        }
        
//        let host = PreferencePlist.pacServerListenHost
        let port = PreferencePlist.pacServerListenPort
        
        do {
            // Alway start server with listen localhost.
            try webServer.start(options: [
                "Port": UInt(port),
                "BindToLocalhost": true
            ])
            NSLog("Start pac server sucess, listen %d port".localized, port)
            self.pacWebServer = webServer
        } catch {
            NSLog("Start pac server failed, msg: \(error.localizedDescription)")
        }
    }
    
    static func stopPACWebServer() -> Void {
        if self.pacWebServer != nil && self.pacWebServer.isRunning {
            self.pacWebServer.stop()
        }
    }
}

//
//  scriptUtils.swift
//  TrojanX
//
//  Created by Sakurai on 2019/12/30.
//  Copyright © 2019 Sakurai. All rights reserved.
//

import Foundation
import Cocoa


let APP_SCRIPT_DIR = "/Library/Application Scripts/"
let LAUNCH_AGENT_CONF_TROJAN = "com.huimingz.TrojanX.trojan.plist"
let TROJAN_CONF_NAME = "trojan_config.json"
let TROJAN_LOG_FILE = "/Library/Logs/trojan.log"

var trojanTask: Process?


func generateTrojanLaunchAgentPlist() {
    //    let trojanExecPath = "/Users/sakurai/Library/Application Scripts/com.huimingz.TrojanX/trojan"
    //    let trojanConfPath = "/Users/sakurai/Library/Application Scripts/com.huimingz.TrojanX/config.json"
    //    let logFilePath = NSHomeDirectory() + "/Library/Logs/trojan.log"
    //    let plistPath = NSHomeDirectory() + APP_SCRIPT_DIR + LAUNCH_AGENT_CONF_TROJAN
    //    let arguments = [trojanExecPath, "-c", trojanConfPath]
    //
    //    let dict: NSMutableDictionary = [
    //        "Label": "com.huimingz.TrojanX.trojan",
    //        "WorkingDirectory": NSHomeDirectory() + APP_SCRIPT_DIR,
    //        "StandardOutPath": logFilePath,
    //        "StandardErrorPath": logFilePath,
    //        "ProgramArguments": arguments,
    //    ]
    //
    //    let app_scrript_path = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    //
    //
    //    let res = dict.write(to: (app_scrript_path?.appendingPathComponent(LAUNCH_AGENT_CONF_TROJAN))!, atomically: true)
    //    NSLog("write bool -> \(res)")
    
    //    let trojanExecPath = Bundle.main.path(forResource: "trojan", ofType: nil)!
    //    var destPath = try? FileManager.default.url(for: .applicationScriptsDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    //    destPath =  destPath?.appendingPathComponent("trojans")
    //    try? FileManager.default.copyItem(at: URL(fileURLWithPath: trojanExecPath), to: destPath!)
}


func launchTrojanPlist() {
    //    let scriptPath = Bundle.main.path(forResource: "start_trojan_service.sh", ofType: nil)
    //    let task = Process.launchedProcess(launchPath: scriptPath!, arguments: [""])
    //
    //    task.waitUntilExit()
    //    NSLog("launch trojan service termination status: \(task.terminationStatus)")
    
    //    let res = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

func gererateTrojanConfig(_ trojanProfile: TrojanFullProfile) -> Bool {
    let appSupportDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first! + "/" + Bundle.appName() + "/"
    if !FileManager.default.fileExists(atPath: appSupportDir) {
        try! FileManager.default.createDirectory(atPath: appSupportDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    return trojanProfile.writeToFile(filepath: appSupportDir + TROJAN_CONF_NAME)
}


func startTrojan() {
    stopTrojan()
    
    let app_support_dir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
    let script_path = Bundle.main.path(forResource: "trojan", ofType: nil)!
    let config_path = app_support_dir + "/" + Bundle.appName() + "/" + TROJAN_CONF_NAME
    let log_file_path = NSHomeDirectory() + TROJAN_LOG_FILE
    
    trojanTask = Process()
    trojanTask?.launchPath = script_path
    trojanTask?.arguments = ["-c", config_path, "-l", log_file_path]
//     trojanTask?.arguments = ["-c", config_path]
    trojanTask?.launch()
//    trojanTask?.terminationHandler = {
//        (p:Process) in
//        let notify = NSUserNotification()
//        notify.title = "Success".localized
//        notify.informativeText = "TrojanX | stop trojan service sucess.".localized
//        notify.soundName = NSUserNotificationDefaultSoundName
//        NSUserNotificationCenter.default.deliver(notify)
//    }
    
    if let status = trojanTask?.isRunning, status {
        let notify = NSUserNotification()
        notify.title = "Success".localized
        notify.informativeText = "TrojanX | trojan is running.".localized(comment: "trojan is running")
        notify.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notify)
    }
    
    var trojanServiceInfo = UserDefaults.standard.dictionary(forKey: "TrojanService") ?? [String: Any]()
    trojanServiceInfo["PID"] = trojanTask?.processIdentifier
    PreferencePlist.trojanServicePID = Int(trojanTask!.processIdentifier)
}


func stopTrojan() {
    if let status = trojanTask?.isRunning, status {
        trojanTask?.terminate()
        PreferencePlist.trojanServicePID = 0
    } else {
        let pid = PreferencePlist.trojanServicePID
        if pid != 0 {
            let task = Process()
            task.launchPath = "/bin/kill"
            task.arguments = ["\(pid)"]
            task.launch()
            
            PreferencePlist.trojanServicePID = 0
        }
    }
    
    trojanTask = nil
}


extension Bundle {
    static func appName() -> String {
        guard let dictionary = Bundle.main.infoDictionary else {
            return "TrojanX"
        }
        if let version : String = dictionary["CFBundleName"] as? String {
            return version
        } else {
            return "TrojanX"
        }
    }
}

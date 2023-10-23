//
//  AppInfoManager.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/27/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation

class AppInfoManager {
    public static let shared = AppInfoManager()
    
    func getBuildVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
//        let build = dictionary["CFBundleVersion"] as! String
//        return "\(version).\(build)"
        return "\(version)"
    }
    
    func getBuildTime() -> String {
        let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
           
        { return "\(formatter.string(from: infoDate))"}
        
        return "\(formatter.string(from: Date()))"
    }
    
    func handleNewVersionDB() {
        if let versionApp = KeyvalueDB.getVersionApp() {
            if(versionApp != getBuildVersion()) {
                KeyvalueDB.deleteAll()
                KeyvalueDB.putVersionApp(version: getBuildVersion())
            }
        } else {
            KeyvalueDB.deleteAll()
            KeyvalueDB.putVersionApp(version: getBuildVersion())
        }
    }
    
    func getAppName() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
}

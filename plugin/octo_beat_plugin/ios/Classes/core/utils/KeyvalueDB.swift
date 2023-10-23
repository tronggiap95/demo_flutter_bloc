//
//  KeyvalueDB.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/28/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation

class KeyvalueDB {
    static let preference = UserDefaults.standard
    static let DASHBOARD_LIFECYCLE = "dashboard_lifecycle"
    static let CURRENT_VERSION_APP = "current_version_app"
    static let APP_INVISIBLE = "app_invisible"
    
    static func putAppInvisible(isInvisible: Bool) {
        preference.set(isInvisible, forKey: APP_INVISIBLE)
        preference.synchronize()
    }
    
    static func getAppInvisible() -> Bool {
        if let isInvisible = preference.object(forKey: APP_INVISIBLE){
            return isInvisible as! Bool
        } else {
            return false
        }
    }
    
    static func putDashboardLifeycle(isActive: Bool) {
        preference.set(isActive, forKey: DASHBOARD_LIFECYCLE)
        preference.synchronize()
    }
    
    static func getDashboardLifecycle() -> Bool {
        if let isActive = preference.object(forKey: DASHBOARD_LIFECYCLE){
            return isActive as! Bool
        } else {
            return false
        }
    }
    
    static func putVersionApp(version: String) {
        preference.set(version, forKey: CURRENT_VERSION_APP)
        preference.synchronize()
    }
    
    static func getVersionApp() -> String? {
        if let version = preference.object(forKey: CURRENT_VERSION_APP){
            return version as? String
        } else {
            return nil
        }
    }
    
    static func deleteAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}

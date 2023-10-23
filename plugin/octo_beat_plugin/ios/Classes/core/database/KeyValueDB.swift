//
//  KeyValueDB.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 6/10/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class KeyValueDB {
    static let sharePreference = UserDefaults.standard
    
    static let LOGIN_STATE = "login_state"
    static let ROLE = "role"
    static let MAIL = "mail"
    static let USER_ID = "user_id"
    static let CURRENT_STUDY_REF_CODE = "current_study_ref_code"
    static let CURRENT_DEVICE_TYPE = "current_device_type"
    static let CURRENT_STUDY_TYPE = "current_study_type"
    static let PROFILE_COMPLETED = "profile_completed"
    static let CURRENT_STUDY_IS_ABORTED = "current_study_aborted"
    
    
    static func putLoginState(isLoggedin: Bool){
        sharePreference.set(isLoggedin, forKey: LOGIN_STATE)
    }
    
    static func getLoggedInState() -> Bool {
       return sharePreference.bool(forKey: LOGIN_STATE)
    }
    
    static func putRole(role: Role) {
        sharePreference.set(role.rawValue, forKey: ROLE)
    }
    
    static func getRole() -> Role {
        return Role.get(role: sharePreference.string(forKey: ROLE) ?? "")
    }
    
    static func putMail(mail: String){
        sharePreference.set(mail, forKey: MAIL)
    }
    
    static func getMail() -> String {
        return sharePreference.string(forKey: MAIL) ?? ""
    }
    
    static func putUserId(userId: String){
        sharePreference.set(userId, forKey: USER_ID)
    }
    
    static func getUserId() -> String {
        return sharePreference.string(forKey: USER_ID) ?? ""
    }
    
    static func putCurrentStudyRefCode(code: String){
        sharePreference.set(code, forKey: CURRENT_STUDY_REF_CODE)
    }
    
    static func getCurrentStudyRefCode() -> String {
        return sharePreference.string(forKey: CURRENT_STUDY_REF_CODE) ?? ""
    }
    
    static func putCurrentDeviceType(type: String){
        sharePreference.set(type, forKey: CURRENT_DEVICE_TYPE)
    }
    
    static func getCurrentDeviceType() -> String {
        return sharePreference.string(forKey: CURRENT_DEVICE_TYPE) ?? ""
    }
    
    static func putProfileComplted(completed: Bool) {
        sharePreference.set(completed, forKey: PROFILE_COMPLETED)
    }
    
    static func getProfileComplted() -> Bool {
        return sharePreference.bool(forKey: PROFILE_COMPLETED)
    }
    
    static func putStudyType(type: String){
        sharePreference.set(type, forKey: CURRENT_STUDY_TYPE)
    }
    
    static func getStudyType() -> String {
        return sharePreference.string(forKey: CURRENT_STUDY_TYPE) ?? ""
    }
    
    static func putCurrentStudyIsAborted(isAborted: Bool){
        sharePreference.set(isAborted, forKey: CURRENT_STUDY_IS_ABORTED)
    }
    
    static func getCurrentStudyIsAborted() -> Bool {
        return sharePreference.bool(forKey: CURRENT_STUDY_IS_ABORTED)
    }
    
 
}

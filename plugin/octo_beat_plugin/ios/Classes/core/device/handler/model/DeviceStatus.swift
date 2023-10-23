//
//  DeviceStatus.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

enum StudyInfo: String {
    case STUDY_READY = "Ready for new study"
    case STUDY_SETTING = "Setting up"
    case STUDY_PROGRESS = "Study is in progress"
    case STUDY_PAUSE = "Study Paused"
    case STUDY_COMPLETED = "Study Completed"
    case STUDY_UPLOADED = "Study Uploaded"
    case STUDY_UPLOADING = "Uploading study data"
    case STUDY_ABORTED = "Aborted"
}

public class DeviceStatus {
    var battLevel: UInt8!
    
    var battCharging: Bool!
    var battLow: Bool!
    var battTime: UInt16!
    
    var raStatus: Bool!
    var laStatus: Bool!
    var llStatus: Bool!
    
    var studyStatus: String!
    
    func getStudyInfo() -> StudyInfo {
        switch studyStatus {
        case "Ready for new study":
            return .STUDY_READY
        case "Setting up":
            return .STUDY_SETTING
        case "Study is in progress":
            return .STUDY_PROGRESS
        case "Study Paused":
            return .STUDY_PAUSE
        case "Study Completed":
            return .STUDY_COMPLETED
        case "Study Uploaded":
            return .STUDY_UPLOADED
        default:
            return .STUDY_UPLOADING
        }
    }
    
    func isLeadOn() -> Bool {
        return raStatus && laStatus && llStatus
    }
}

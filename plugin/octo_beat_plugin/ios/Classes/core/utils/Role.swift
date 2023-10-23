//
//  Role.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 2021-04-03.
//  Copyright © 2021 itr.vn. All rights reserved.
//

import Foundation

enum Role: String, CaseIterable {
    case CLINIC_TECHNICIAN = "Clinic Technician"
    case CLINIC_PHYSICIAN = "Clinic Physician"
    case PATIENT = "Patient";
    
    public static func get(role: String) -> Role {
        for r in  Role.allCases {
            if(role == r.rawValue) {
                return r
            }
        }
        return Role.PATIENT
    }
}

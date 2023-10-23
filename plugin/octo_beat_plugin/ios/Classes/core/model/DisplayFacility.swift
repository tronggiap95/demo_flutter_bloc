//
//  Facility.swift
//  OctoBeat-clinic-ios
//
//  Created by Ta  Quoc Cuong on 5/14/22.
//  Copyright © 2022 itr.vn. All rights reserved.
//

import Foundation

class DisplayFacility {
    var facilityID: String!
    var name: String!
    var status: String!
    
    init(facilityID: String, name: String, status: String) {
        self.facilityID = facilityID
        self.name = name
        self.status = status
    }
}

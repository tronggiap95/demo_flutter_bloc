//
//  RSP_GET_TIME.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 9/17/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class RSP_GET_TIME: CommandParams {
    var responseCode: ResponseCode!
    var utcTime: Int64!
    var timeZone: Int!

    init(responseCode: ResponseCode, utcTime: Int64, timeZone: Int ) {
        self.responseCode = responseCode
        self.utcTime = utcTime
        self.timeZone = timeZone
    }
}

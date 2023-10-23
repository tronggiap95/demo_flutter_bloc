//
//  NetStatusParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class RSP_NET_STATUS_PR: CommandParams {
    var responseCode: ResponseCode!
    var netStatus: Bool!
    
    init(responseCode: ResponseCode, netStatus: Bool) {
        self.responseCode = responseCode
        self.netStatus = netStatus
    }
}

//
//  DataTCPParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class RSP_READ_TCP_PR: CommandParams {
    var responseCode: ResponseCode!
    var bytes: Data!
    
    init(responseCode: ResponseCode, bytes: Data) {
        self.responseCode = responseCode
        self.bytes = bytes
    }
}

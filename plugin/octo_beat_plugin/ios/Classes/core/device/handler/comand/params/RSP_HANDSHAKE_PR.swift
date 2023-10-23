//
//  HandshakeParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class RSP_HANDSHAKE_PR: CommandParams {
    var responseCode: ResponseCode!
    var time: Int64!
    var timezone: Int!
    var preferredMode: String!
    
    init(responseCode: ResponseCode, time: Int64, timezone: Int, preferredMode: String) {
        self.responseCode = responseCode
        self.time = time
        self.timezone = timezone
        self.preferredMode = preferredMode
    }
}

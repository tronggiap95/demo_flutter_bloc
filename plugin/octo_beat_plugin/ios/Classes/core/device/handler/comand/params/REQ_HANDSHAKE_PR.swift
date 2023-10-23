//
//  REQ_HANDSHAKE_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/7/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation

class REQ_HANDSHAKE_PR: CommandParams {
    var packetVersion: Int!
    var apiVersion: Int!
    var deviceId: String!
    var classicSupport: Bool!
    
    init(packetVersion: Int, apiVersion: Int, deviceId: String!, classicSupport: Bool){
        self.packetVersion = packetVersion
        self.apiVersion = apiVersion
        self.deviceId = deviceId
        self.classicSupport = classicSupport
    }
}

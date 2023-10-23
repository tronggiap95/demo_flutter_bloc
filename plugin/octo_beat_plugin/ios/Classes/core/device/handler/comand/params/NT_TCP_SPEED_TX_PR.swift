//
//  NT_TCP_SPEED_TX_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/29/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation

class NT_TCP_SPEED_TX_PR: CommandParams {
    var connectionId: UInt8
    var speed: Int
    
    init(connectionId: UInt8, speed: Int) {
        self.connectionId = connectionId
        self.speed = speed
    }
}

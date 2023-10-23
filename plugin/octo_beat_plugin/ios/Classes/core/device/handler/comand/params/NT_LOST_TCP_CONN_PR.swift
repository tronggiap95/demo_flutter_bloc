//
//  NT_LOST_TCP_CONN_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NT_LOST_TCP_CONN_PR: CommandParams {
    var connectionId: UInt8
    
    init(connectionId: UInt8){
        self.connectionId = connectionId
    }
}

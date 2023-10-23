//
//  ReceiveTCPDataParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
class NT_RECEIVE_TCP_DATA_PR: CommandParams {
    var connectionId: Int!
    var length: Int
    
    init(connectionId: Int, length: Int){
        self.connectionId = connectionId
        self.length = length
    }
}

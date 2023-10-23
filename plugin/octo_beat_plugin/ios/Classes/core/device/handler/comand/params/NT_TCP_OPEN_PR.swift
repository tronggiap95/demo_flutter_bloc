//
//  NT_TCP_OPEN_PR.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 09/12/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class NT_TCP_OPEN_PR: CommandParams {
    var connectionId: Int!
    var isConnected: Bool!
    
    init(connectionId: Int, isConnected: Bool) {
        self.connectionId = connectionId
        self.isConnected = isConnected
    }
}

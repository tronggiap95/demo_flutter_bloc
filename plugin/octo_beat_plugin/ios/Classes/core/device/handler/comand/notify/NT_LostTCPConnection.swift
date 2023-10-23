//
//  NT_LostTCPConnection.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class NT_LostTCPConnection: NotifyCommand{
    func build(params: CommandParams) -> Command {
        let parameters = params as! NT_LOST_TCP_CONN_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(NotifyCode.BB_NT_TCP_CONN_LOST.rawValue)))
        array.append(.int(Int64(parameters.connectionId)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

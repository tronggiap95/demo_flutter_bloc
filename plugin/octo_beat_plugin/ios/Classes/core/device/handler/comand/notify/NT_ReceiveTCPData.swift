//
//  NT_ReceiveTCPData.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class NT_ReceiveTCPData: NotifyCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! NT_RECEIVE_TCP_DATA_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(NotifyCode.BB_NT_TCP_RX_DATA_RDY.rawValue)))
        array.append(.int(Int64(parameters.connectionId)))
        array.append(.int(Int64(parameters.length)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

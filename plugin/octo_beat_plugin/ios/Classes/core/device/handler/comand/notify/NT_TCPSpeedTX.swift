//
//  NT_TCPSpeedTX.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/29/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation
import MessagePack

class NT_TCPSpeedTX: NotifyCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! NT_TCP_SPEED_TX_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(NotifyCode.BB_NT_TCP_TX_SPEED.rawValue)))
        array.append(.int(Int64(parameters.connectionId)))
        array.append(.int(Int64(parameters.speed)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

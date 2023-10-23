//
//  NT_NetStatusChange.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class NT_NetStatusChange: NotifyCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! NT_NET_CHANGE_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(NotifyCode.BB_NT_NETSTAT_UPDATE.rawValue)))
        array.append(.bool(parameters.status))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

//
//  NT_TCPOpen.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 09/12/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation
import MessagePack

class NT_TCPOpen: NotifyCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! NT_TCP_OPEN_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(NotifyCode.BB_NT_TCP_CONN_OPEN_REPORT.rawValue)))
        array.append(.int(Int64(parameters.connectionId)))
        array.append(.bool(parameters.isConnected))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

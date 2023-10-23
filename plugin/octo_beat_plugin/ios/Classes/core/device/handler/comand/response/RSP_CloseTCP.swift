//
//  CloseTCP_RSP.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_CloseTCP: ResponseCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_CLOSE_TCP_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_TCP_CLOSE_CONN.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

//
//  HandShakeRsp.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_HandShake: ResponseCommand{
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_HANDSHAKE_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_HANDSHAKE.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        array.append(.int(Int64(parameters.time)))
        array.append(.int(Int64(parameters.timezone)))
        array.append(.string(parameters.preferredMode))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

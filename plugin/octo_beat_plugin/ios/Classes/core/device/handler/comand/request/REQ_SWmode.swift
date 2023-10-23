//
//  REQ_SWmode.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class REQ_SWmode: RequestCommand {
    func build(params: CommandParams) -> Command {
        let responseCode = params as! REQ_SW_MODE_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_SWITCH_BT_MODE.rawValue)))
        array.append(.string(responseCode.mode))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

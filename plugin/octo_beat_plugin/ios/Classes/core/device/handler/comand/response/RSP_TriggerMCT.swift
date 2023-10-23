//
//  RSP_TriggerMCT.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_TriggerMCT: ResponseCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_TRIGGER_MCT_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_EVENT_TRIGGERED.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

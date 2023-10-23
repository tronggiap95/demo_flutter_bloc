//
//  REQ_ConfirmMCT.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class REQ_ConfirmMCT: RequestCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! REQ_CONFIRM_MCT_PR
        
        var arraySymptoms: [MessagePackValue] = []
        parameters.symptoms.forEach{
            symtomp in
            arraySymptoms.append(.int(Int64(symtomp)))
        }
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_EVENT_CONFIRMED.rawValue)))
        array.append(.int(Int64(parameters.time)))
        array.append(.array(arraySymptoms))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

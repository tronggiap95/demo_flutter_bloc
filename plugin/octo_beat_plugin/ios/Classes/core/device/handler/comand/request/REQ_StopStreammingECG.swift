//
//  REQ_StopStreammingECG.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class REQ_StopStreammingECG: RequestCommand {
    func build(params: CommandParams) -> Command {
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_STOP_STREAMING_ECG.rawValue)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

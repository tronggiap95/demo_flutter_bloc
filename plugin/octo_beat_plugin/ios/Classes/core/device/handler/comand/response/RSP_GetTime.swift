//
//  RSP_GetTime.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 9/17/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation
import MessagePack

class RSP_GetTime: ResponseCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_GET_TIME
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_GET_TIME.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        
        if parameters.responseCode == ResponseCode.BB_RSP_OK {
            array.append(.uint(UInt64(parameters.utcTime)))
            array.append(.int(Int64(parameters.timeZone)))
        }
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

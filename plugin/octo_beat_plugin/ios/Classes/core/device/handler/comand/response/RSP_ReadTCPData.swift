//
//  RSP_ReadTCPData.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_ReadTCPData: ResponseCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_READ_TCP_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_TCP_READ_DATA.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        
        if(parameters.responseCode == ResponseCode.BB_RSP_OK){
            array.append(.binary(parameters.bytes))
        }
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

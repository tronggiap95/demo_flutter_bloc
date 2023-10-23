//
//  RSP_SetServerCer.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_SetServerCer: ResponseCommand{
    func build(params: CommandParams) -> Command {
        let responseCode = params as! RSP_SET_SERVER_CER_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_SSL_SET_CA_CERT.rawValue)))
        array.append(.int(Int64(responseCode.responseCode.rawValue)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

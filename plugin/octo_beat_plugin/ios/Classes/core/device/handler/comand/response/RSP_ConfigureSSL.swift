//
//  ConfigureSSL_RSP.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class RSP_ConfigureSSL: ResponseCommand {
    func build(params: CommandParams) -> Command {
        let parameters = params as! RSP_CONFIG_SSL_PR
        
        var array: [MessagePackValue] = []
        array.append(.int(Int64(RequestCode.BB_REQ_SSL_CONN_CONFIG.rawValue)))
        array.append(.int(Int64(parameters.responseCode.rawValue)))
        
        return buildPacket(payloadData: pack(.array(array)))
    }
}

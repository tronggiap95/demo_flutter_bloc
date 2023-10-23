//
//  ResponseHandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 22/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation
import MessagePack

public class ResponseHandler: DeviceHandler {
    
    static func isInvalidParams(packet: Packet) -> Bool {
        if(!isResponse(packet: packet)) {
            return true
        }
        
        if let code = getCode(packet: packet ){
            return isInvalidCode(code: code)
        }
        
        return false
    }
    
    static func isResponse(packet: Packet) -> Bool {
        if(StatusCode.get(code: packet.status) != StatusCode.RESPONSE) {
            return false
        }
        return true
    }
    
    static func isInvalidCode(code: UInt16) -> Bool{
        if(RequestCode.get(value: code) != nil) {
            return false
        }
        return true
    }
}

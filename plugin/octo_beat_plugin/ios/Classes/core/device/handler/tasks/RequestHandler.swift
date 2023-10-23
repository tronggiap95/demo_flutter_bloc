//
//  RequestHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

public class RequestHandler: DeviceHandler {
    static func isInvalidParams(packet: Packet) -> Bool {
        if(!isRequest(packet: packet)) {
            return true
        }
        
        if let code = getCode(packet: packet) {
            return isInvalidCode(code: code)
        }
        
        return false
    }
    
    static func isRequest(packet: Packet) -> Bool {
        if(StatusCode.get(code: packet.status) != StatusCode.REQUEST) {
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

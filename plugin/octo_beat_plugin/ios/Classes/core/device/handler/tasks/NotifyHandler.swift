//
//  NotifyHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack
public class NotifyHandler: DeviceHandler {
    static func isInvalidParams(packet: Packet) -> Bool {
        if(!isNotify(packet: packet)) {
            return true
        }
        if  let code = getCode(packet: packet) {
            return isInvalidCode(code: code)
        }
        return false
    }
    
    static func isNotify(packet: Packet) -> Bool {
        if(StatusCode.get(code: packet.status) != StatusCode.NOTIFY) {
            return false
        }
        return true
    }
    
   static func isInvalidCode(code: UInt16) -> Bool{
        if(NotifyCode.get(value: code) != nil) {
            return false
        }
        return true
    }
}

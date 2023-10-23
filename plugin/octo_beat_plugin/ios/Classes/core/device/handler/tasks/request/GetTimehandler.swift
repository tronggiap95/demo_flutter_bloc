//
//  GetTimehandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 9/17/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class GetTimehandler: RequestHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        let timezoneLocalInMinutes = TimeUtil.getTimezoneLocalInMinutes()
        TimeUtil.getUTCTrueTime() {
            (utcTrueTime) in
            CommandFactory.sendPacket(type:CommandType.RSP_GET_TIME,
                                      params: RSP_GET_TIME(responseCode: ResponseCode.BB_RSP_OK, utcTime: Int64(utcTrueTime)+Int64(timezoneLocalInMinutes*60), timeZone: timezoneLocalInMinutes),
                                      blueHandler: blueHandler)
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            CommandFactory.sendPacket(type:CommandType.RSP_GET_TIME,
                                      params: RSP_GET_TIME(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION, utcTime: 0, timeZone: 0),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_GET_TIME,
                                      params: RSP_GET_TIME(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION, utcTime: 0, timeZone: 0),
                                      blueHandler: bluetoothHandler)
            return true
            
        }
        
        return false
    }
}

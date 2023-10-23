//
//  TriggerMCTHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class TriggerMCTHandler: RequestHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 2) {
            if let time = values[1].intValue {
                callback?.eventMCTTrigger(time: time, bluetoothHandler: blueHandler)
                
                let param = RSP_TRIGGER_MCT_PR(responseCode:ResponseCode.BB_RSP_OK)
                CommandFactory.sendPacket(type: CommandType.RSP_TRGGER_MCT,
                                          params: param,
                                          blueHandler: blueHandler)
            }
        }
        
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            let param = RSP_TRIGGER_MCT_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION)
            CommandFactory.sendPacket(type:CommandType.RSP_TRGGER_MCT,
                                      params: param,
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            let param = RSP_TRIGGER_MCT_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM)
            CommandFactory.sendPacket(type: CommandType.RSP_TRGGER_MCT,
                                      params: param,
                                      blueHandler: bluetoothHandler)
            return true        }
        
        return false
    }
}

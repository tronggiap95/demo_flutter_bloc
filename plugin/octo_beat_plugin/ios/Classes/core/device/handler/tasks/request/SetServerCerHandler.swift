//
//  SetServerCerHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class SetServerCerHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 3) {
            if  let cerId = values[1].uint8Value,
                let cert =  values[2].stringValue {
                socketHandler.serverCA[cerId] = cert
                
                CommandFactory.sendPacket(type: CommandType.RSP_SET_SERVER_CER,
                                          params: RSP_SET_SERVER_CER_PR(responseCode: ResponseCode.BB_RSP_OK),
                                          blueHandler: blueHandler)
            }
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler?, packet: Packet) -> Bool {
        guard bluetoothHandler!.isConnected else {
            return true
        }
        
        guard bluetoothHandler!.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_SET_SERVER_CER,
                                      params: RSP_SET_SERVER_CER_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_SET_SERVER_CER,
                                      params: RSP_SET_SERVER_CER_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

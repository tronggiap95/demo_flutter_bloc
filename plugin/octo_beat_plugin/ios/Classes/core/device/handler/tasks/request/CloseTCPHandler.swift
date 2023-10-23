//
//  CloseTCPHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class CloseTCPHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        socketHandler.datas.removeAll()
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 2) {
            if let connectionId = values[1].uint8Value {
                let params = RSP_CLOSE_TCP_PR(responseCode: ResponseCode.BB_RSP_OK)
                CommandFactory.sendPacket(type: CommandType.RSP_CLOSE_TCP,
                                          params: params,
                                          blueHandler: blueHandler)
            }
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            let params = RSP_CLOSE_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION)
            CommandFactory.sendPacket(type: CommandType.RSP_CLOSE_TCP,
                                      params: params,
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            let params = RSP_CLOSE_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM)
            params.isSecure = bluetoothHandler.isSecure()
            params.ase = bluetoothHandler.aes
            CommandFactory.sendPacket(type: CommandType.RSP_CLOSE_TCP,
                                      params: params,
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

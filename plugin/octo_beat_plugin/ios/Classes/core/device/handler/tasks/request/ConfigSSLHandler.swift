//
//  ConfigSSLHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class ConfigSSLHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 6) {
            if let connectionId = values[1].uint8Value,
                let authMode = values[2].uint8Value,
                let serverCAId = values[3].uint8Value,
                let clientCAId = values[4].uint8Value,
                let clientPrivateKeyId = values[5].uint8Value {
                socketHandler.addNewTCPConnection(connection:
                    TCPConnection(id: connectionId,
                                  authMode: authMode == 0 ? SSLAuthMode.ONE_WAY_AUTH : SSLAuthMode.TWO_WAY_AUTH,
                                  serverCAId: serverCAId,
                                  clientCAId: clientCAId,
                                  clientPrivateKeyId: clientPrivateKeyId))
                
                CommandFactory.sendPacket(type: CommandType.RSP_CONFIG_SSL,
                                          params: RSP_CONFIG_SSL_PR(responseCode: ResponseCode.BB_RSP_OK),
                                          blueHandler: blueHandler)
            }
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_CONFIG_SSL,
                                      params: RSP_CONFIG_SSL_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_CONFIG_SSL,
                                      params: RSP_CONFIG_SSL_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

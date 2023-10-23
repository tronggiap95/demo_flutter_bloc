//
//  TransmitDataHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/27/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NotifyTransmitDataHandler: NotifyHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let unpackValue = unPackPacket(packet: packet, validCount: 3) {
            if  let connectionId = unpackValue[1].uint8Value, let data = unpackValue[2].dataValue {
                let tcpConnection = socketHandler.getTCPConnection(id: connectionId)
                if(tcpConnection != nil && tcpConnection!.isSSLEnable) {
                    _ =  socketHandler.send(data: data)
                }
            }
        }
        
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        return false
    }
}

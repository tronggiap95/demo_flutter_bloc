//
//  NetStatusHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NetStatusHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        CommandFactory.sendPacket(type: CommandType.RSP_NET_STATUS,
                                  params: RSP_NET_STATUS_PR(responseCode: ResponseCode.BB_RSP_OK, netStatus: socketHandler.isNetworkAvailable()),
                                  blueHandler: blueHandler)
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_NET_STATUS,
                                      params: RSP_NET_STATUS_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION, netStatus: false),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_NET_STATUS,
                                      params: RSP_NET_STATUS_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM, netStatus: false),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

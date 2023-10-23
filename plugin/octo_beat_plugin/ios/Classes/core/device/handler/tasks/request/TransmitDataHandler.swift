//
//  TransmitDataHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/27/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class TransmitDataHandler: RequestHandler {
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler?, packet: Packet) -> Bool {
        guard bluetoothHandler!.isConnected else {
            return true
        }
        
        guard bluetoothHandler!.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_CLOSE_TCP,
                                      params: RSP_CLOSE_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_CLOSE_TCP,
                                      params: RSP_CLOSE_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

//
//  NotifyTCPSpeedTXHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/29/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation

class NotifyTCPSpeedTXHandler: NotifyHandler {
    static func handle(blueHandler: BluetoothHandler, param: NT_TCP_SPEED_TX_PR, callback: DXHDeviceHandlerCallback?) {
        
        guard blueHandler.isConnected else {
            return
        }
        
        CommandFactory.sendPacket(type: CommandType.NT_TCP_SPEED_TX,
                                  params: param,
                                  blueHandler: blueHandler)
    }
}

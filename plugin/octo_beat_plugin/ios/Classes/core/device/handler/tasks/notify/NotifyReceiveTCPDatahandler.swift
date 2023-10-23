//
//  NotifyReceiveTCPDatahandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NotifyReceiveTCPHandler: NotifyHandler {
    public static func handle(blueHandler: BluetoothHandler, dataLength: Int, callback: DXHDeviceHandlerCallback?) {
        guard blueHandler.isConnected else {
            return
        }
        
        CommandFactory.sendPacket(type: CommandType.NT_RECEIVE_TCP_DATA,
                                  params: NT_RECEIVE_TCP_DATA_PR(connectionId: 1, length: dataLength),
                                  blueHandler: blueHandler)
    }
}

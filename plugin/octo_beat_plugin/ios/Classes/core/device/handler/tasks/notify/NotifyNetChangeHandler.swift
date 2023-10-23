//
//  NotifyNetChangeHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NotifyNetChangeHandler: NotifyHandler {
    public static func handle(socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        guard blueHandler.isConnected else {
            return
        }
        
        let params = NT_NET_CHANGE_PR(status: socketHandler.isNetworkAvailable())
        CommandFactory.sendPacket(type: CommandType.NT_NET_CHANGE,
                                  params: params,
                                  blueHandler: blueHandler)
    }
}

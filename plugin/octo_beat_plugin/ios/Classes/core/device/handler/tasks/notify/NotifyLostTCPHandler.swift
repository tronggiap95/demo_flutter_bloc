//
//  NotifyLostTCPHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NotifyLostTCPHandler: NotifyHandler {
    public static func handle(blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        // let socketHandler = params.socketHandler
        guard blueHandler.isConnected else {
            return
        }
        let params = NT_LOST_TCP_CONN_PR(connectionId: 1)
        CommandFactory.sendPacket(type: CommandType.NT_LOST_TCP_CONN,
                                  params: params,
                                  blueHandler: blueHandler)
        
        //        for connection in socketHandler!.tcpConnections {
        //            let data = CommandFactory.buildPacket(type: CommandType.NT_LOST_TCP_CONN, params: NT_LOST_TCP_CONN_PR(connectionId: connection.id))
        //            print("SEND NOTIFY LOST TCP CONNECTION")
        //            bluetoothHandler?.send(data: data)
        //        }
        
    }
}

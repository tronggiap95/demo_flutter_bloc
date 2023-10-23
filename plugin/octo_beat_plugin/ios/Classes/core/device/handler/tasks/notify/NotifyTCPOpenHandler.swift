//
//  NotifyTCPOpenHandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 09/12/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class NotifyTCPOpenHandler: NotifyHandler {
    public static func handle(param: NT_TCP_OPEN_PR, blueHandler: BluetoothHandler?) {
        // let socketHandler = params.socketHandler
        guard blueHandler?.isConnected ?? false else {
            return
        }
        CommandFactory.sendPacket(type: CommandType.BB_NT_TCP_CONN_OPEN_REPORT,
                                  params: param,
                                  blueHandler: blueHandler)
    }
}

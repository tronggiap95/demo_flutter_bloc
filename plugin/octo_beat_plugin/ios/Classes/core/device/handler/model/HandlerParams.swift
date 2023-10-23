//
//  HandlerParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
class HandlerParams {
    var packet: Packet?
    var bluetoothHandler: BluetoothHandler?
    var socketHandler: SocketHandler?
    
    var receivedTCPDataKLength: Int?
    
    var data: CommandParams?
    
    init(packet: Packet?, bluetoothHandler: BluetoothHandler?, socketHandler: SocketHandler?) {
        self.bluetoothHandler = bluetoothHandler
        self.socketHandler = socketHandler
        self.packet = packet
    }
    
    func setRecieveTCPDataLength(length: Int) -> HandlerParams {
        self.receivedTCPDataKLength = length
        return self
    }
    
    func setParams(data: CommandParams){
        self.data = data
    }
}

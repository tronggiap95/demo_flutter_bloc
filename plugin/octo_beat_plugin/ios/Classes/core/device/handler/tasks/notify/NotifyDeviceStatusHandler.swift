//
//  DeviceStatusHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack
class NotifyDeviceStatushandler : NotifyHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        guard !isInvalidParams(packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 8) {
            let deviceStatus = getDeviceStatus(values: values, bluetoothHander: blueHandler)
            callback?.updateDeviceStatus(deviceStatus: deviceStatus, bluetoothHandler: blueHandler)
        }
    }
    
    private static func getDeviceStatus(values: [MessagePackValue], bluetoothHander: BluetoothHandler) -> DeviceStatus {
        let deviceStatus = DeviceStatus()
        deviceStatus.battLevel = values[1].uint8Value
        
        if(bluetoothHander.apiVersion < 1) {
            deviceStatus.battCharging =  values[2].boolValue
            deviceStatus.battLow = deviceStatus.battLevel < 10 && deviceStatus.battLevel > 0
        } else {
            deviceStatus.battCharging = values[2].intValue == 2
            deviceStatus.battLow = values[2].intValue == 1 && deviceStatus.battLevel > 0
        }
        deviceStatus.battTime =  values[3].uint16Value
        
        deviceStatus.raStatus =  values[4].boolValue
        deviceStatus.laStatus =  values[5].boolValue
        deviceStatus.llStatus =  values[6].boolValue
        
        deviceStatus.studyStatus =  values[7].stringValue
        
        return deviceStatus
    }
}

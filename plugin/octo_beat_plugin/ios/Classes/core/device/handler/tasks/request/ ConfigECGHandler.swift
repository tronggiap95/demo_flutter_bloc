//
//   ConfigECGHandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 17/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class ConfigECGHandler: ResponseHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        if(isResponseFailed(bluetoothHandler: blueHandler, packet: packet)) {
            return
        }
        if let values = unPackPacket(packet: packet, validCount: 4){
            if let responseCode = values[1].uint16Value,
                let gain = values[2].doubleValue,
                let channel = values[3].stringValue,
                let sampleRate = values[4].intValue {
                if (responseCode == ResponseCode.BB_RSP_OK.rawValue) {
                    callback?.updateECGConfig(ecgConfig: ECGConfig(gain: gain, channel: channel, sampleRate: sampleRate), bluetoothHandler: blueHandler)
                }
            }
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            return true
        }
        
        return false
    }
}

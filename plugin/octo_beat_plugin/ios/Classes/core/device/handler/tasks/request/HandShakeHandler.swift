//
//  HandShakeHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import TrueTime

class HandShakeHandler: RequestHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 5) {
            if let packetVersion = values[1].intValue,
                let apiVersion = values[2].intValue,
                let clientId = values[3].stringValue,
                let classicSupport = values[4].boolValue {
                blueHandler.isHandshaked = true
                blueHandler.apiVersion = apiVersion
                response(responseCode: ResponseCode.BB_RSP_OK, bluetoothHandler: blueHandler)
                callback?.handShakeDone(handshakePR: REQ_HANDSHAKE_PR(packetVersion: packetVersion, apiVersion: apiVersion, deviceId: clientId, classicSupport: classicSupport), bluetoothHandler: blueHandler)
            }
            
        }
    }
    
    private static func response(responseCode: ResponseCode, bluetoothHandler: BluetoothHandler) {
        let timezoneLocalInMinutes = TimeUtil.getTimezoneLocalInMinutes()
        print("TIMZONE: ", timezoneLocalInMinutes)
        TimeUtil.getUTCTrueTime() {
            (utcTrueTime) in
           CommandFactory.sendPacket(type: CommandType.RSP_HANDSHAKE,
                                     params: RSP_HANDSHAKE_PR(responseCode: responseCode, time: Int64(utcTrueTime)+Int64(timezoneLocalInMinutes*60) , timezone: timezoneLocalInMinutes, preferredMode: BlueMode.BLE.rawValue),
            blueHandler: bluetoothHandler)
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            self.response(responseCode: ResponseCode.BB_RSP_ERR_PARAM, bluetoothHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

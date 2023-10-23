//
//  ObjectParser.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation

class ObjectParser {
    static func parseDeviceInfo(device: DeviceDisplay) -> [String: Any]? {
        let deviceStatus = device.deviceStatus
        let isLeadConnected = deviceStatus?.isLeadOn() ?? false
        let batLevel = deviceStatus?.battLevel ?? 0
        let isCharging = deviceStatus?.battCharging ?? false
        let batLow = deviceStatus?.battLow ?? true
        let batTime = deviceStatus?.battTime ?? 0
        let isConnected = device.connectionDeviceStatus
        let name = device.deviceName ?? ""
        let address = device.deviceId?.uuidString ?? ""
        let isServerConnected = device.connectionTCPStatus
        let studyStatus = deviceStatus?.studyStatus ?? ""
        
        return [
            "isConnected": isConnected,
            "name": name,
            "address": address,
            "batLow": batLow,
            "batTime": batTime,
            "batLevel": batLevel,
            "isCharging": isCharging,
            "isLeadConnected": isLeadConnected,
            "isServerConnected": isServerConnected,
            "studyStatus": studyStatus
        ]
    }
}

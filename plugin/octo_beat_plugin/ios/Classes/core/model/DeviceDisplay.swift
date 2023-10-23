//
//  DeviceDisplay.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/27/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

public class DeviceDisplay {
    var deviceId: UUID?
    var deviceName: String!
    var facility: DisplayFacility?
    
    var deviceStatus: DeviceStatus?
    var connectionTCPStatus: Bool = false
    var connectionDeviceStatus: Bool = false
    
    var type: UpdateType = .DEVICE_CONNECTION
    
    var tx: Int64 = 0
    var rx: Int64 = 0
    
    var isEdit = false
    
    var mctEventTime: Int?
    
    init(deviceName: String, facility: DisplayFacility?) {
        self.deviceName = deviceName
        self.facility = facility
    }
    
    init(deviceName: String, deviceId: UUID?) {
        self.deviceId = deviceId
        self.deviceName = deviceName
    }

    init(deviceName: String, deviceId: UUID, facility: DisplayFacility) {
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.facility = facility
    }
    
    func update(device: DeviceDisplay) {
        self.deviceId = device.deviceId
        self.deviceStatus = device.deviceStatus
        self.connectionDeviceStatus = device.connectionDeviceStatus
        self.connectionTCPStatus = device.connectionTCPStatus
        self.mctEventTime = device.mctEventTime
        self.rx = device.rx
        self.tx = device.tx
        self.type = device.type
    }
    
    func updateTxSocket(size: Int64) {
        self.tx += size
    }
    
    func updateRxSocket(size: Int64) {
        self.rx += size
    }
    
    func getbattInfo() -> String {
        return ""
    }
    
    func getMCTEventTime() -> Int {
        if let time = mctEventTime {
            return 20 - (Int(Date().millisecondsSince1970/1000) - time)
        } else {
            return 0
        }
    }
    
    func updateDeviceConnectionStatus(isConnected: Bool) {
        if(!isConnected){
            tx = 0
            rx = 0
            deviceStatus = nil
            connectionTCPStatus = false
            connectionDeviceStatus = false
            type = .DEVICE_CONNECTION
        }
        connectionDeviceStatus = isConnected
    }
    
    func updateDeviceStatus(currentStatus: DeviceStatus) {
        deviceStatus = currentStatus
    }
    
    func updateNewMCTEvent(mctEventTime: Int) {
        self.mctEventTime = mctEventTime
    }
}

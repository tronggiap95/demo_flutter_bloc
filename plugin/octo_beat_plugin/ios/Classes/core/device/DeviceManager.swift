//
//  TrafficManager.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/20/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import RxSwift
protocol DeviceManagerCallback: class {
    func newDevice(device: DeviceDisplay)
    func updateDeviceStatus(deviceStastus: DeviceStatus, identify: UUID)
    func updateDeviceConnection(status: Bool, identify: UUID)
    func updateServerTCPConnection(status: Bool, identify: UUID)
    func newMCTEvent(time: Int, identify: UUID)
    func updateTx(size: Int64, identify: UUID)
    func updateRx(size: Int64, identify: UUID)
    func updateECGData(data: Data, identify: UUID)
    func updateECGConfig(ecgConfig: ECGConfig, identify: UUID)
}

class DeviceManager{
    public static var sharedInstance = DeviceManager()
    private var dxhDeviceHandlers: [DXHDeviceHandler] = []
    private var callbacks = [DeviceManagerCallback]()
    
    private init() {
        BluetoothManager.sharedInstance.registerConnectionCallback(self)
        BluetoothManager.sharedInstance.registerBluetoothStateDelegate(self)
    }
    
    func registerDeviceManagerCallback(_ delegate: DeviceManagerCallback) {
        self.callbacks.append(delegate)
    }
    
    func removeDeviceMangerCallback(_ delegate: DeviceManagerCallback) {
        self.callbacks.removeAll {$0 === delegate}
    }
    
    private func notifyECGData(data: Data, identify: UUID) {
        callbacks.forEach{
            $0.updateECGData(data: data, identify: identify)
        }
    }
    
    private func notifyECGConfig(ecgConfig: ECGConfig, identify: UUID) {
        callbacks.forEach{
            $0.updateECGConfig(ecgConfig: ecgConfig, identify: identify)
        }
    }
    
    private func notifyTxSocket(size: Int64, identify: UUID) {
        callbacks.forEach{
            $0.updateTx(size: size, identify: identify)
        }
    }
    private func notifyRxSocket(size: Int64, identify: UUID) {
        callbacks.forEach{
            $0.updateRx(size: size, identify: identify)
        }
    }
    
    private func notifyNewDevice(device: DeviceDisplay) {
        callbacks.forEach{
            $0.newDevice(device: device)
        }
    }
    
    private func notifyDeviceStatus(deviceStastus: DeviceStatus, identify: UUID) {
        callbacks.forEach{
            $0.updateDeviceStatus(deviceStastus: deviceStastus, identify: identify)
        }
    }
    
    private func notifyDeviceConnection(status: Bool, identify: UUID) {
        callbacks.forEach{
            $0.updateDeviceConnection(status: status, identify: identify)
        }
    }
    
    private func notifyServerTCPConnection(status: Bool, identify: UUID) {
        callbacks.forEach{
            $0.updateServerTCPConnection(status: status, identify: identify)
        }
    }
    
    private func notifynewMCTEvent(time: Int, identify: UUID) {
        callbacks.forEach{
            $0.newMCTEvent(time: time, identify: identify)
        }
    }
    
    func getBlueHandler(deviceId: UUID) -> BluetoothHandler? {
        if let index = hasDeviceHandler(identify: deviceId) {
            return dxhDeviceHandlers[index].bluetoothHandler
        }
        return nil
    }
    
    private func hasDeviceHandler(identify: UUID?) -> Int?{
        for (index,device) in dxhDeviceHandlers.enumerated() {
            if(device.identify == identify) {
                return index
            }
        }
        return nil
    }
    
    private func removeDeviceHandler(identify: UUID?) {
        if let index = hasDeviceHandler(identify: identify) {
            dxhDeviceHandlers.remove(at: index)
        }
    }
    
    func sendBle(data: Data, deviceId: UUID) {
        if let index = hasDeviceHandler(identify: deviceId) {
            dxhDeviceHandlers[index].sendBle(data: data)
        }
    }
    
    func sendSock(data: Data, deviceId: UUID) {
        if let index = hasDeviceHandler(identify: deviceId) {
            dxhDeviceHandlers[index].sendSock(data: data)
        }
    }
    
    func forcedAllRemove() {
        dxhDeviceHandlers.forEach{ handler in
            handler.forceStop()
        }
        dxhDeviceHandlers.removeAll()
    }
    
    func forceRemove(uuid: UUID) {
        dxhDeviceHandlers.forEach{
            handler in
            if(handler.identify == uuid) {
                handler.forceStop()
            }
        }
        dxhDeviceHandlers.removeAll(where: {$0.identify == uuid})
    }
}

extension DeviceManager: ConnectionCallback, bluetoothSatusDelegate {
    
    func bluetoothOn() {
        dxhDeviceHandlers.forEach{ handler in
            BluetoothManager.sharedInstance.reconnect(handler.bluetoothHandler!.pheripheral!.identifier, period: 30, startAfter: 5)
        }
    }
    func bluetoothOff() {
        BluetoothManager.sharedInstance.dispoAllReconnectings()
        dxhDeviceHandlers.forEach{ handler in
            handler.forceStop()
        }
    }
    
    func onConnected(bluetoothHandler: BluetoothHandler) {
        if let deviceId = bluetoothHandler.deviceId {
            notifyDeviceConnection(status: true, identify: deviceId)
            let dxhDeviceHandler = DXHDeviceHandler(bluetoothHandler: bluetoothHandler, callback: self)
            removeDeviceHandler(identify: deviceId)
            dxhDeviceHandlers.append(dxhDeviceHandler)
        }
    }
    
    func onConnectedFailed(bluetoothHandler: BluetoothHandler) {
        if let deviceId = bluetoothHandler.deviceId {
            notifyDeviceConnection(status: false, identify: deviceId)
            removeDeviceHandler(identify: deviceId)
        }
    }
    
    func onDisconnected(bluetoothHandler: BluetoothHandler) {
        if let deviceId = bluetoothHandler.deviceId {
            notifyDeviceConnection(status: false, identify: deviceId)
            BluetoothManager.sharedInstance.reconnect(deviceId, period: 30, startAfter: 5)
        }
    }
}

extension DeviceManager: DXHDeviceHandlerCallback {
    func updateDeviceStatus(deviceStatus: DeviceStatus, bluetoothHandler: BluetoothHandler?) {
        notifyDeviceStatus(deviceStastus: deviceStatus, identify: bluetoothHandler!.deviceId!)
    }
    
    func eventMCTTrigger(time: Int, bluetoothHandler: BluetoothHandler?) {
        notifynewMCTEvent(time: time, identify: bluetoothHandler!.deviceId!)
    }
    
    func notifyTCPStatus(connected: Bool, bluetoothHandler: BluetoothHandler?) {
        notifyServerTCPConnection(status: connected, identify: bluetoothHandler!.deviceId!)
    }
    
    func handShakeDone(handshakePR: REQ_HANDSHAKE_PR, bluetoothHandler: BluetoothHandler?) {
        let device = DeviceDisplay(deviceName: handshakePR.deviceId, deviceId: bluetoothHandler!.deviceId!)
        if KeyValueDB.getRole() != .PATIENT, let dv = CoreManager.sharedInstance.getDevices().first(where: {$0.deviceName == handshakePR.deviceId}) {
            device.facility = dv.facility
        }
        device.updateDeviceConnectionStatus(isConnected: bluetoothHandler!.isConnected)
        bluetoothHandler?.pheripheral?.shallBeSaved = true
        notifyNewDevice(device: device)
    }
    
    func errorPacketParser(bluetoothHandler: BluetoothHandler?) {
        notifyDeviceConnection(status: false, identify: bluetoothHandler!.deviceId!)
    }
    
    func updateRx(size: Int64, bluetoothHandler: BluetoothHandler?) {
        guard bluetoothHandler?.deviceId != nil else {
            return
        }
        notifyRxSocket(size: size, identify: bluetoothHandler!.deviceId!)
    }
    
    func updateTx(size: Int64, bluetoothHandler: BluetoothHandler?) {
        guard bluetoothHandler?.deviceId != nil else {
            return
        }
        notifyTxSocket(size: size, identify: bluetoothHandler!.deviceId!)
    }
    
    func updateECGData(data: Data, bluetoothHandler: BluetoothHandler?) {
        guard bluetoothHandler?.deviceId != nil else {
            return
        }
        notifyECGData(data: data, identify: bluetoothHandler!.deviceId!)
    }
    
    func updateECGConfig(ecgConfig: ECGConfig, bluetoothHandler: BluetoothHandler?) {
        guard bluetoothHandler?.deviceId != nil else {
            return
        }
        notifyECGConfig(ecgConfig:ecgConfig , identify: bluetoothHandler!.deviceId!)
    }
}

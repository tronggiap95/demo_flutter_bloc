//
//  CoreHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/20/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import RxSwift

@objc
enum UpdateType: Int {
    case DEVICE_STATUS
    case DEVICE_CONNECTION
    case SERVER_TCP_CONNECTION
    case NEW_DEVICE
    case TX_RX_TCP
}

@objc
protocol CoreEventCallback: class {
    func updateUI(updateType: UpdateType, deviceId: UUID)
    @objc optional func updateECGData(data: Data, deviceId: UUID)
    @objc optional func updateECGConfig(ecgConfig: ECGConfig, deviceId: UUID)
}

protocol TriggerMCTEvent: class {
    func newMCTEvent(deviceId: UUID)
}

class CoreManager{
    private let TAG = "CORE_HANDLER"
    public static var sharedInstance = CoreManager()
    
    private var devices: [DeviceDisplay] = []
    private var devicesWithDraftStudy: [String] = []

    private var callbacks = [CoreEventCallback]()
    
    private var mctEventTriggers = [TriggerMCTEvent]()
        
    private var isReconnectingFinishingWhenOpening = false
    
    private var lastUpdateRX: Int64 = 0
    private var lastUpdateTx: Int64 = 0
    
    private let defaults = UserDefaults.standard
    //MARK: Variables
    var deviceId: String? {
        get {
            return defaults.string(forKey: "OCTO_BEAT_DEVICE_ID")
        }
        set {
            defaults.set(newValue, forKey: "OCTO_BEAT_DEVICE_ID")
        }
    }
    
    var deviceName: String? {
        get {
            return defaults.string(forKey: "OCTO_BEAT_DEVICE_NAME")
        }
        set {
            defaults.set(newValue, forKey: "OCTO_BEAT_DEVICE_NAME")
        }
    }
    
    
    private init(){
        DeviceManager.sharedInstance.registerDeviceManagerCallback(self)
        BluetoothManager.sharedInstance.registerBluetoothStateDelegate(self)
    }
    
    func getDevices() -> [DeviceDisplay] {
        return devices
    }
    
    func registerCoreEvent(_ callback: CoreEventCallback) {
        callbacks.append(callback)
    }
    
    func removeCoreEvent(_ callback: CoreEventCallback) {
        callbacks.removeAll {$0 === callback}
    }
    
    func registerMCTEvent(_ callback: TriggerMCTEvent) {
        mctEventTriggers.append(callback)
    }
    
    func removeMCTEvent(_ callback: TriggerMCTEvent) {
        mctEventTriggers.removeAll {$0 === callback}
    }
    
    func NotifyUI(updateType: UpdateType, deviceId: UUID) {
        DispatchQueue.main.async {
            self.callbacks.forEach{
                $0.updateUI(updateType: updateType, deviceId: deviceId)}
        }
    }
    
    private func NotifyMCTEvent(deviceId: UUID) {
        DispatchQueue.main.async {
            self.mctEventTriggers.forEach{ $0.newMCTEvent(deviceId: deviceId)}
        }
    }
    
    private func NotifyECGData(data: Data, deviceId: UUID) {
        self.callbacks.forEach{
            $0.updateECGData?(data: data, deviceId: deviceId)
        }
    }
    
    private func NotifyECGConfig(ecgConfig: ECGConfig, deviceId: UUID) {
        DispatchQueue.main.async {
            self.callbacks.forEach{
                $0.updateECGConfig?(ecgConfig: ecgConfig, deviceId: deviceId)
            }
        }
    }
    
    func getDeviceDisplay(deviceId: UUID) -> DeviceDisplay? {
        return devices.first(where: {$0.deviceId == deviceId})
    }
    
    func saveDevice(device: DeviceDisplay) {
        if let id = device.deviceId {
            deviceId = device.deviceId!.uuidString
            deviceName = device.deviceName
            let success = BluetoothManager.sharedInstance.saveDevice(uuid: id)
            LogUtil.myLogInfo(clazz: self.TAG, methodName: "SAVE DEVICE: ", message: "\(success)")
        }
    }

    func getListDeviceWithDraftStudy() -> [String] {
        return self.devicesWithDraftStudy
    }
    
    func adđDeviceWithDraftStudy(deviceName: String) {
        self.devicesWithDraftStudy.append(deviceName)
    }

    func removeDeviceWithDraftStudy(deviceName: String) {
        self.devicesWithDraftStudy.removeAll(where: { dv in dv == deviceName })
    }

    func clearListDeviceWithDraftStudy() {
        self.devicesWithDraftStudy = []
    }
}

extension CoreManager: DeviceManagerCallback {
    func newDevice(device: DeviceDisplay) {
        isReconnectingFinishingWhenOpening = true
        saveDevice(device: device)
        if let dv = devices.first(where: {$0.deviceName == device.deviceName}) {
            dv.deviceId = device.deviceId
            getDeviceDisplay(deviceId: device.deviceId!)?.updateDeviceConnectionStatus(isConnected: true)
        } else {
            devices.append(device)
        }
        NotifyUI(updateType: UpdateType.NEW_DEVICE, deviceId: device.deviceId!)
    }
    
    func updateDeviceStatus(deviceStastus: DeviceStatus, identify: UUID) {
        //  monitorAppTerminated()
        print("updateDeviceStatus 1")
        if let deviceDisplay = getDeviceDisplay(deviceId: identify) {
            print("updateDeviceStatus 2")
            deviceDisplay.updateDeviceStatus(currentStatus: deviceStastus)
            self.NotifyUI(updateType: UpdateType.DEVICE_STATUS, deviceId: identify)
        }
    }
    
    func newMCTEvent(time: Int, identify: UUID) {
        getDeviceDisplay(deviceId: identify)?.updateNewMCTEvent(mctEventTime: time)
        NotifyMCTEvent(deviceId: identify)
        
    }
    
    func updateDeviceConnection(status: Bool, identify: UUID) {
        getDeviceDisplay(deviceId: identify)?.updateDeviceConnectionStatus(isConnected: status)
        NotifyUI(updateType: UpdateType.DEVICE_CONNECTION, deviceId: identify)
    }
    
    func updateServerTCPConnection(status: Bool, identify: UUID) {
        getDeviceDisplay(deviceId: identify)?.connectionTCPStatus = status
        NotifyUI(updateType: UpdateType.SERVER_TCP_CONNECTION, deviceId: identify)
    }
    
    func updateRx(size: Int64, identify: UUID) {
        getDeviceDisplay(deviceId: identify)?.updateRxSocket(size: size)
        let currentUpdateTime = Date().millisecondsSince1970
        if currentUpdateTime - lastUpdateRX > 1000 {
            NotifyUI(updateType: UpdateType.TX_RX_TCP, deviceId: identify)
            lastUpdateRX = currentUpdateTime
        }
    }
    
    func updateTx(size: Int64, identify: UUID) {
        getDeviceDisplay(deviceId: identify)?.updateTxSocket(size: size)
        let currentUpdateTime = Date().millisecondsSince1970
        if currentUpdateTime - lastUpdateTx > 1000 {
            NotifyUI(updateType: UpdateType.TX_RX_TCP, deviceId: identify)
            lastUpdateTx = currentUpdateTime
        }
    }
    
    func updateECGData(data: Data, identify: UUID) {
        NotifyECGData(data: data, deviceId: identify)
    }
    
    func updateECGConfig(ecgConfig: ECGConfig, identify: UUID) {
        NotifyECGConfig(ecgConfig: ecgConfig, deviceId: identify)
    }
}

extension CoreManager: bluetoothSatusDelegate {
    func EnterBackgroundHandler() {
        devices.forEach{
            $0.connectionTCPStatus = false
            $0.connectionDeviceStatus = false
            if let id = $0.deviceId {
                NotifyUI(updateType: .DEVICE_CONNECTION, deviceId: id)
            }
        }
        DeviceManager.sharedInstance.forcedAllRemove()
        BluetoothManager.sharedInstance.dispoAllReconnectings()
    }
    
    func forceStopAllDevices() {
        DeviceManager.sharedInstance.forcedAllRemove()
        BluetoothManager.sharedInstance.deleteAllDevice()
        devices.removeAll()
    }
    
    func deleteAllDevices() {
        devices.forEach{ device in
            if let id = device.deviceId {
                deleteDevice(uuid: id)
            }
        }
        forceStopAllDevices()
    }
    
    func deleteDevice(uuid: UUID) {
        BluetoothManager.sharedInstance.deleteDevice(uuid: uuid)
        DeviceManager.sharedInstance.forceRemove(uuid: uuid)
        devices.removeAll(where: {$0.deviceId == uuid})
        deviceId = nil
        deviceName = nil
    }
    
    func disconnectDevice(uuid: UUID) {
        BluetoothManager.sharedInstance.deleteDevice(uuid: uuid)
        DeviceManager.sharedInstance.forceRemove(uuid: uuid)
    }
    
    func initAllDevices() {
        devices.removeAll()
        if(deviceId != nil && deviceName != nil) {
            let device = DeviceDisplay(deviceName: deviceName!, deviceId: UUID(uuidString: deviceId!)!)
            devices.append(device)
        }
    }
    
    func initDevice() -> DeviceDisplay? {
        devices.removeAll()
        if(deviceId != nil && deviceName != nil) {
            let device = DeviceDisplay(deviceName: deviceName!, deviceId: UUID(uuidString: deviceId!)!)
            devices.append(device)
            return device
        }
        return nil
    }
    
    func reconnectWhenOpen() -> Bool {
        isReconnectingFinishingWhenOpening = false
        if(BluetoothManager.sharedInstance.isPowerOn()) {
            reconnectAllDevices()
            return true
        }
        return false
    }
    
    func bluetoothOn() {
        if(!isReconnectingFinishingWhenOpening) {
            reconnectAllDevices()
        }
    }
    
    private func reconnectAllDevices() {
        devices.forEach{
            device in
            if (!device.connectionDeviceStatus) {
                if let id = device.deviceId {
                    BluetoothManager.sharedInstance.reconnect(id, period: 30, startAfter: 5)
                }
            }
        }
    }
    
    func bluetoothOff() {
        devices.forEach{
            device in device.updateDeviceConnectionStatus(isConnected: false)
        }
    }
    
}

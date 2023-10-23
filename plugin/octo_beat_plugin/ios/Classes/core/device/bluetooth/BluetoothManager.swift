//
//  BluetoothManager.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/20/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import RxSwift
import CoreBluetooth

protocol ConnectionCallback: class {
    func onConnected(bluetoothHandler: BluetoothHandler)
    func onConnectedFailed(bluetoothHandler: BluetoothHandler)
    func onDisconnected(bluetoothHandler: BluetoothHandler)
}

protocol bluetoothSatusDelegate: class {
    func bluetoothOn()
    func bluetoothOff()
}

class BluetoothManager: NSObject {
    public static var sharedInstance = BluetoothManager()
    private var manager = TIOManager.sharedInstance(with: DispatchQueue(label: "OctoBeat.clinic.bluetooth.queue", attributes: .concurrent))
    private var callbacks =  [ConnectionCallback]()
    private var delegates = [bluetoothSatusDelegate]()
    private var scanObserver: (AnyObserver<TIOPeripheral>)?
    private var central: CBCentralManager!
    private var isBluetoothOn = false
    private var handlers = [BluetoothHandler]()
    private var isCanReconnect = false
    private var currentFailedReconnectingUUID: UUID?
    
    private override init(){
        super.init()
        self.manager?.delegate = self
    }
}

extension BluetoothManager: TIOManagerDelegate {
    func tioManagerBluetoothAvailable(_ manager: TIOManager!) {
        isBluetoothOn = true
        notifyBluetoothStatus(powerOn: true)
    }
    
    func tioManagerBluetoothUnavailable(_ manager: TIOManager!) {
        isBluetoothOn = false
        notifyBluetoothStatus(powerOn: false)
        scanObserver?.onError(RxError(message: "Scan failed"))
    }
    
    func tioManager(_ manager: TIOManager!, didDiscover peripheral: TIOPeripheral!) {
        print("scan found \(peripheral.name)")
        peripheral.shallBeSaved = false
        scanObserver?.onNext(peripheral)
    }
    
    func tioManager(_ manager: TIOManager!, didRetrievePeripheral peripheral: TIOPeripheral!) {
    }
    
    
    func startScan() -> Observable<TIOPeripheral>? {
        return Observable<TIOPeripheral>.create{ (observer) in
            self.scanObserver = observer
            self.manager?.peripherals.forEach{
                if(!($0 as! TIOPeripheral).shallBeSaved) {
                    self.manager?.removePeripheral(($0 as! TIOPeripheral))
                }
            }
            self.manager?.startUpdateScan()
            return Disposables.create()
        }
    }
    
    func stopScan(){
        self.manager?.stopScan()
    }
}

extension BluetoothManager{
    
    func registerBluetoothStateDelegate(_ delegate: bluetoothSatusDelegate) {
        self.delegates.append(delegate)
    }
    
    func removeBluetoothStateDelegate(_ delegate: bluetoothSatusDelegate) {
        self.delegates.removeAll {$0 === delegate}
    }
    
    func isPowerOn() -> Bool {
        return isBluetoothOn
    }
    
    func isBluetoothAuthorized() -> Bool { 
        if #available(iOS 13.1, *) { return CBCentralManager.authorization == .allowedAlways }
        if #available(iOS 13.0, *) { return CBCentralManager().authorization == .allowedAlways }
        return true
    }
    
    func notifyBluetoothStatus(powerOn: Bool) {
        DispatchQueue.main.async {
            self.delegates.forEach{
                if(powerOn) {
                    $0.bluetoothOn()
                } else {
                    $0.bluetoothOff()
                }
            }
        }
    }
    
}

extension BluetoothManager: BluetoothHandlerCallback {
    func registerConnectionCallback(_ delegate: ConnectionCallback) {
        self.callbacks.append(delegate)
    }
    
    func removeConnectionCallback(_ delegate: ConnectionCallback) {
        self.callbacks.removeAll {$0 === delegate}
    }
    
    private func notifyConnected(bluetoothHandler: BluetoothHandler) {
        callbacks.forEach{
            $0.onConnected(bluetoothHandler: bluetoothHandler)
        }
    }
    
    private func notifyConnectFailed(bluetoothHandler: BluetoothHandler) {
        callbacks.forEach{
            $0.onConnectedFailed(bluetoothHandler: bluetoothHandler)
        }
    }
    
    private func notifyDisconnected(bluetoothHandler: BluetoothHandler) {
        callbacks.forEach{
            $0.onDisconnected(bluetoothHandler: bluetoothHandler)
        }
    }
    
    func connect(_ pheripheral: TIOPeripheral){
        dispoReconnecting(uuid: pheripheral.identifier)
        let bluetoothHandler = BluetoothHandler()
        bluetoothHandler.registerCallback(self)
        bluetoothHandler.connect(pheripheral)
        handlers.append(bluetoothHandler)
    }
    
    func reconnect(_ uuid: UUID, period: Double, startAfter: Double) {
        dispoReconnecting(uuid: uuid)
        let bluetoothHandler = BluetoothHandler()
        bluetoothHandler.registerCallback(self)
        bluetoothHandler.isAutoReconnect = true
        bluetoothHandler.reconnect(uuid, period: period, startAfter: startAfter)
        handlers.append(bluetoothHandler)
    }
    
    func dispoAllReconnectings() {
        handlers.forEach{
            $0.dispoReconnect?.dispose()
        }
        handlers.removeAll()
    }
    
    func dispoReconnecting(uuid: UUID){
        for (index, handler) in handlers.enumerated().reversed() {
            if(handler.deviceId == uuid){
                LogUtil.myLogInfo(clazz: "BLUETOOTH MANAGER", methodName: "DISPOSE RECONNECTING", message: "DEVICE: \(uuid)")
                handler.dispoReconnect?.dispose()
                handlers.remove(at: index)
            }
        }
    }
    
    func onConnected(bluetoothHandler: BluetoothHandler) {
        self.notifyConnected(bluetoothHandler: bluetoothHandler)
    }
    
    func onConnectedFailed(bluetoothHandler: BluetoothHandler) {
        self.notifyConnectFailed(bluetoothHandler: bluetoothHandler)
    }
    
    func onDisconnected(bluetoothHandler: BluetoothHandler) {
        self.notifyDisconnected(bluetoothHandler: bluetoothHandler)
    }
    
    func loadSavedPheripheral(){
        self.manager?.loadPeripherals()
    }
    
    func deleteAllDevice() {
        self.dispoAllReconnectings()
        self.manager?.removeAllPeripherals()
    }
    
    func deleteDevice(uuid: UUID) {
        self.dispoReconnecting(uuid: uuid)
        if let peripheral =  hasTIOpheripheral(uuid: uuid) {
            peripheral.shallBeSaved = false
            self.manager?.removePeripheral(peripheral)
        }
    }
    
    func saveDevice(uuid: UUID) -> Bool{
        if let tioPheripheral = hasTIOpheripheral(uuid: uuid) {
            tioPheripheral.shallBeSaved = true
            self.manager?.savePeripherals()
        }
        return false
    }
    
    func removePheripheral(uuid: UUID) {
        if let tioPheripheral = hasTIOpheripheral(uuid: uuid) {
            tioPheripheral.shallBeSaved = false
            self.manager?.removePeripheral(tioPheripheral)
        }
    }
    
    func hasTIOpheripheral(uuid: UUID) -> TIOPeripheral? {
        if let pheripherals =  manager?.peripherals{
            for item  in pheripherals {
                let tioPheripheral = item as! TIOPeripheral
                if tioPheripheral.identifier == uuid {
                    return tioPheripheral
                }
            }
        }
        return nil
    }
    
}

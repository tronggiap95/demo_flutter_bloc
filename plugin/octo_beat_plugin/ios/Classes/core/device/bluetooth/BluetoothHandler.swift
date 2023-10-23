//
//  BluetoothHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/21/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift

 protocol BluetoothHandlerCallback: class {
    func onConnected(bluetoothHandler: BluetoothHandler)
    func onConnectedFailed(bluetoothHandler: BluetoothHandler)
    func onDisconnected(bluetoothHandler: BluetoothHandler)
}

class BluetoothHandler: NSObject {
    private let TAG: String = "BLUETOOTH_HANDLER"
    private var callbacks = [BluetoothHandlerCallback]()
    var pheripheral: TIOPeripheral?
    var datas = BlockingQueue<Data?>()
    var deviceName: String?
    var deviceId: UUID?
    var dispoReconnect: Disposable?
    
    var isConnected: Bool = false
    var isHandshaked: Bool = false
    var isAutoReconnect: Bool = true
    
    var apiVersion: Int = 0
    var aes: AESManager?
    var protoVersion: Int = 0

    func isSecure() -> Bool {
        return protoVersion > 0
    }

    func registerCallback(_ callback: BluetoothHandlerCallback) {
        self.callbacks.append(callback)
    }
    
    func removeCallback(_ callback: BluetoothHandlerCallback) {
        self.callbacks.removeAll {$0 === callback}
    }
    
    private func notifyConnected() {
        self.callbacks.forEach{
            $0.onConnected(bluetoothHandler: self)
        }
    }
    
    private func notifyDisconnected() {
        self.callbacks.forEach{
            $0.onDisconnected(bluetoothHandler: self)
        }
    }
    
    private func notifyConnectFailed() {
        self.callbacks.forEach{
            $0.onConnectedFailed(bluetoothHandler: self)
        }
    }
    
    func connect(_ pheripheral: TIOPeripheral)  {
        self.deviceId = pheripheral.identifier
        self.pheripheral = pheripheral
        self.pheripheral?.delegate = self
        self.pheripheral?.connect()
    }
    
    func reconnect(_ uuid: UUID, period: Double, startAfter: Double){
        guard isAutoReconnect else {
            return
        }
        self.deviceId = uuid
        dispoReconnect = Observable<Int>.timer(.seconds(Int(startAfter)), period: .seconds(Int(period)), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribe(onNext: { retries in
                self.pheripheral?.cancelConnection()
                self.pheripheral = nil
                let manager = TIOManager.sharedInstance()
                let tioPeripheral = manager?.createPeripheral(uuid)
                if let tioPeripheral = tioPeripheral {
                    self.pheripheral = tioPeripheral
                    LogUtil.myLogInfo(clazz: self.TAG, methodName: "reconnect", message: "RECONNECT-\(tioPeripheral.isConnected) TIMES: \(retries)")
                    self.connect(tioPeripheral)
                } else {
                    self.dispoReconnect?.dispose()
                    self.dispoReconnect = nil
                }
            }, onError: { error in
                LogUtil.myLogInfo(clazz: self.TAG, methodName: "reconnect", message: "RECONNECT FAILED")
            })
    }
    
    public func close() {
        LogUtil.cloudLog(message: "BLUETOOTH STATE: CLOSE")
        pheripheral?.cancelConnection()
        BluetoothManager.sharedInstance.removePheripheral(uuid: pheripheral!.identifier)
        isConnected = false
        isHandshaked = false
        datas.removeAll()
        dispoReconnect?.dispose()
        dispoReconnect = nil
        LogUtil.myLogInfo(clazz: TAG, methodName: "CLOSE: ", message: "BLUETOOTH IS CLOSED")
    }
    
    public func forcedClose() {
         callbacks.removeAll()
         isAutoReconnect = false
         close()
         LogUtil.myLogInfo(clazz: TAG, methodName: "CLOSE: ", message: "BLUETOOTH IS FORCECLOSED")
    }
    
    
    func send(data: Data){
     pheripheral?.writeUARTData(data)
     LogUtil.myLogInfo(clazz: TAG, methodName: "send", message: "DATA: \(data.toHexString())")
    }
    
}

extension BluetoothHandler: TIOPeripheralDelegate {
    public func tioPeripheralDidConnect(_ peripheral: TIOPeripheral!) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "didConnect", message: "DEVICE: \(peripheral.name!)")
        self.dispoReconnect?.dispose()
        self.dispoReconnect = nil
        self.isConnected = true
        self.deviceId = pheripheral?.identifier
        self.deviceName = pheripheral?.name
        if let deviceName = self.deviceName {
            aes = AESManager(deviceName: deviceName)
        }
        self.notifyConnected()
    }

    public func tioPeripheral(_ peripheral: TIOPeripheral!, didFailToConnectWithError error: Error!) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "didFailConnect", message: "DEVICE: \(peripheral.name!)")
        self.notifyConnectFailed()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {

    }

    public func tioPeripheral(_ peripheral: TIOPeripheral!, didDisconnectWithError error: Error!) {
        LogUtil.cloudLog(message: "BLUETOOTH STATE: DISCONNECTED")
        LogUtil.myLogInfo(clazz: TAG, methodName: "didDisconnect", message: "DEVICE: \(peripheral.name!)")
        self.isConnected = false
        self.isHandshaked = false
        self.datas.removeAll()
        self.notifyDisconnected()
    }

    public func tioPeripheral(_ peripheral: TIOPeripheral!, didReceiveUARTData data: Data!) {
        LogUtil.myLogInfo(clazz: self.TAG, methodName: "didReceiveNewData", message: "DEVICE: \(peripheral.name!) data: \(data.toHexString())")
        self.datas.add(data)
    }

}

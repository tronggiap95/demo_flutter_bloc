//
//  ScannerPlugin.swift
//  Runner
//
//  Created by Manh Tran on 11/10/2022.
//

import Foundation
import CoreBluetooth
class ScannerPlugin: NSObject, BleStateListener {
    
    enum Event: String {
        case SCAN_RESULT = "scanResult"
        case BLUETOOTH_STATE = "bluetoothState"
    }
    
    enum Method: String {
        case HAS_BLE_PERMISSION = "hasBlePermssion"
        case IS_BLE_ENABLE = "isBleEnable"
    }
    
    private let bluetoothEventHandler = EventHandler()
    
    static func register(with messenger: FlutterBinaryMessenger){
        BleStateController.shared.initialization()
        let instance = ScannerPlugin()
        let channel = FlutterMethodChannel(name: "com.octomed.octo360.scanner/ble_scanner_plugin", binaryMessenger: messenger)
        channel.setMethodCallHandler(instance.handle)
        
        let bluetoothEvent = FlutterEventChannel(name: "com.octomed.octo360.scanner/ble_scanner_plugin/bluetooth_state", binaryMessenger: messenger)
        bluetoothEvent.setStreamHandler(instance.bluetoothEventHandler)
        BleStateController.shared.setListener(listener: instance)
                
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case Method.HAS_BLE_PERMISSION.rawValue:
            let hasPermission = BleStateController.shared.isBluetoothAuthorized()
            result(hasPermission)
            break
        case Method.IS_BLE_ENABLE.rawValue:
            let isEnable = BleStateController.shared.isBluetoothEnable()
            result(isEnable)
            break
        default:
            result(nil)
        }
    }
    
    func onBluetoothOn() {
        let dic = [
            "state": "on",
        ];
        
        bluetoothEventHandler.send(event: Event.BLUETOOTH_STATE.rawValue, body: dic)
    }
    
    func onBluetoothOff() {
        let dic = [
            "state": "off",
        ];
        
        bluetoothEventHandler.send(event: Event.BLUETOOTH_STATE.rawValue, body: dic)
    }
    
    func didFound(_ peripheral: CBPeripheral!, advertisementData: [String : Any]!, rssi RSSI: NSNumber!) {
    }
    
}


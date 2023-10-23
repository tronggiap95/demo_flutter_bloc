//
//  OctoBeatConnectionHelper.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 10/02/2023.
//

import Foundation
import RxSwift
import Flutter

class OctoBeatConnectionHelper: NSObject {
    static let shared: OctoBeatConnectionHelper = OctoBeatConnectionHelper()
    
    private var devices: [TIOPeripheral] = []
    private var isCanning = false
    private var scanDisposable: Disposable? = nil
    private var scanIntervalDisposable: Disposable? = nil
    private var octoBeatConnectionCallback: OctoBeatConnectionCallback? = nil
    
    func setConnectionCallback(callback: OctoBeatConnectionCallback) {
        octoBeatConnectionCallback = callback
    }
    
    func registerCoreEventCallback() {
        CoreManager.sharedInstance.registerCoreEvent(self)
    }
    
    func startScanInterval(result: @escaping FlutterResult) {
        self.startIntervalScan()
        result(true)
    }
    
    func stopScanInterval(result: @escaping FlutterResult) {
        self.stopIntervalScan()
        result(true)
    }
    
    func connect(params: Array<Any>?, result: @escaping FlutterResult) {
        guard let uuid = params?[0] as? String else {
            return
        }
        guard let device = self.getUUIDDevice(uuid: uuid)  else {
            return
        }
        
        self.stopIntervalScan()
        BluetoothManager.sharedInstance.connect(device)
    }
    
    func deleteDevice(result: @escaping FlutterResult) {
        CoreManager.sharedInstance.deleteAllDevices()
        result(true)
    }
    
    private func stopScan() {
        isCanning = false
        scanDisposable?.dispose()
        BluetoothManager.sharedInstance.stopScan()
    }
    private func stopIntervalScan() {
        stopScan()
        scanIntervalDisposable?.dispose()
    }
    private func startScan () {
        self.stopScan()
        self.isCanning = true
        self.devices.removeAll()
        self.scanDisposable = BluetoothManager.sharedInstance.startScan()?.subscribe(onNext: {device in
            if device.name != "" {
                self.devices.append(device)
                let mapDevices = self.createMapFoundedDevices()
                self.octoBeatConnectionCallback?.onFoundOctoBeat(devices: mapDevices)
            }
        }, onError: {error in
            print("errorerror \(error)")
            self.scanDisposable?.dispose()
        })
    }
    private func startIntervalScan() {
        scanIntervalDisposable = Observable<Int>.timer(.seconds(0), period: .seconds(5), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: {_ in
                self.startScan()
            }, onError: {_ in})
    }
    
}
extension OctoBeatConnectionHelper: CoreEventCallback {
    func updateUI(updateType: UpdateType, deviceId: UUID) {
        print("OctoBeatConnectionHelper updateType \(updateType.rawValue)")
        switch updateType {
        case .NEW_DEVICE:
            print("OctoBeatConnectionHelper NEW_DEVICE")
            let device = devices.first{ $0.identifier == deviceId }
            guard let device else {return}
            let mapDevice = self.createDeviceMap(
                name: device.name,
                address: device.identifier.uuidString
            )
            octoBeatConnectionCallback?.onConnectedOctoBeat(device: mapDevice)
            break
        default:
            break
        }
    }
}

extension OctoBeatConnectionHelper {
    private func getUUIDDevice(uuid: String) -> TIOPeripheral? {
        for device in self.devices {
            if(uuid == device.identifier.uuidString) {
                return device
            }
        }
        return nil
    }
    
    private func createMapFoundedDevices() -> [[String:String]] {
        var devices = [[String:String]]()
        self.devices.forEach {
            devices.append(
                [
                    "name" : $0.name,
                    "address" : $0.identifier.uuidString
                ]
            )
        }
        return devices
    }
    
    private func createDeviceMap(name: String, address: String)-> [String:String] {
        return [
            "name" : name,
            "address" : address
        ]
    }
}

//
//  OctoBeatConnectionPlugin.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation
import Flutter

class OctoBeatConnectionPlugin: NSObject {
    private static let methodChannel = "com.octo.octo_beat_plugin.plugin.connection/method"
    private static let eventChannel = "com.octo.octo_beat_plugin.plugin.connection/event"
                                    
    enum Event: String {
        case FOUND_DEVICES = "foundDevice"
        case CONNECT_SUCCESS = "connectSuccess"
        case CONNECT_FAIL = "connectFailed"
    }
    
    enum Method: String {
        case START_SCAN = "startScan"
        case STOP_SCAN = "stopScan"
        case CONNECT = "connect"
        case DELETE_DEVICE = "deleteDevice"
    }
    
    private let eventHandler = EventHandler()

    
    static func register(with messenger: FlutterBinaryMessenger){
        let instance = OctoBeatConnectionPlugin()
        
        let channel = FlutterMethodChannel(name: methodChannel, binaryMessenger: messenger)
        channel.setMethodCallHandler(instance.handle)
        
        let event = FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
        event.setStreamHandler(instance.eventHandler)
        
        OctoBeatConnectionHelper.shared.registerCoreEventCallback()
        OctoBeatConnectionHelper.shared.setConnectionCallback(callback: instance)
    }
    
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? Array<Any>
        print("OctoBeatConnectionPlugin call.method \(call.method)")
        switch call.method {
        case Method.START_SCAN.rawValue:
            OctoBeatConnectionHelper.shared.startScanInterval(result: result)
            break
        case Method.STOP_SCAN.rawValue:
            OctoBeatConnectionHelper.shared.stopScanInterval(result: result)
            break
        case Method.CONNECT.rawValue:
            OctoBeatConnectionHelper.shared.connect(params: params, result: result)
            break
        case Method.DELETE_DEVICE.rawValue:
            OctoBeatConnectionHelper.shared.deleteDevice(result: result)
            break
        default:
            result(nil)
        }
    }
}


extension OctoBeatConnectionPlugin: OctoBeatConnectionCallback {
    func onFoundOctoBeat(devices: [[String : String]]) {
        eventHandler.send(event: Event.FOUND_DEVICES.rawValue, body: ["devices": devices])
    }
    
    func onConnectedOctoBeat(device: [String : String]) {
        eventHandler.send(event: Event.CONNECT_SUCCESS.rawValue, body: device)
    }
    
    func onConnectFailOctoBeat() {
        eventHandler.send(event: Event.CONNECT_FAIL.rawValue, body: nil)
    }
}

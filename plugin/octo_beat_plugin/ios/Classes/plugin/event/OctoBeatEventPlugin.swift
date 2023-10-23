//
//  OctoBeatEventPlugin.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation
import Flutter

class OctoBeatEventPlugin: NSObject {
    private static let eventChannel = "com.octo.octo_beat_plugin.plugin.event/event"
    private let eventHandler = EventHandler()

    enum Event: String {
        //DEVICE INFORMATION
        case UPDATE_INFO = "OctoBeat_updateInfo"
        
        //MCT STATUS
        case MCT_TRIGGER = "OctoBeat_mctTrigger"
    }
    
    static func register(with messenger: FlutterBinaryMessenger){
        let instance = OctoBeatEventPlugin()
 
        let event = FlutterEventChannel(name: eventChannel, binaryMessenger: messenger)
        event.setStreamHandler(instance.eventHandler)
        
        OctoBeatEventHelper.shared.registerCoreEventCallback()
        OctoBeatEventHelper.shared.setEventHandlerCallback(callback: instance)
    }
}
 
extension OctoBeatEventPlugin: OctoBeatEventCallback {
    // ****************************** DEVICE INFO UPDATES ******************************
    func updateInfo(device: DeviceDisplay) {
        let deviceMap = ObjectParser.parseDeviceInfo(device: device)
        eventHandler.send(event: Event.UPDATE_INFO.rawValue, body: deviceMap)
    }
    
    // ****************************** MCT TRIGGER ******************************
    func newMCTEvent(deviceId: UUID) {
        guard let device = CoreManager.sharedInstance.getDeviceDisplay(deviceId: deviceId) else {
            return
        }
        let mctEventTime = device.mctEventTime
        eventHandler.send(event: Event.MCT_TRIGGER.rawValue, body: ["mctEventTime": mctEventTime ?? 0])
    }
}


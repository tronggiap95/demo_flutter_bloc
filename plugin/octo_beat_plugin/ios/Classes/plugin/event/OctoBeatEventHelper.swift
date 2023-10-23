//
//  OctoBeatEventHelper.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation

class OctoBeatEventHelper: NSObject {
    static let shared: OctoBeatEventHelper = OctoBeatEventHelper()
    var mOctoBeatEventCallback: OctoBeatEventCallback?
   
    func setEventHandlerCallback(callback: OctoBeatEventCallback) {
        mOctoBeatEventCallback = callback
    }
    
    func registerCoreEventCallback() {
        CoreManager.sharedInstance.registerCoreEvent(self)
        CoreManager.sharedInstance.registerMCTEvent(self)
    }
}

extension OctoBeatEventHelper: CoreEventCallback, TriggerMCTEvent {
    func newMCTEvent(deviceId: UUID) {
        mOctoBeatEventCallback?.newMCTEvent(deviceId: deviceId)
    }
    
    func updateUI(updateType: UpdateType, deviceId: UUID) {
        guard let device = CoreManager.sharedInstance.getDeviceDisplay(deviceId: deviceId) else {
            return
        }
        mOctoBeatEventCallback?.updateInfo(device: device)
    }
}

//
//  OctoBeatEventCallback.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 09/02/2023.
//

import Foundation

protocol OctoBeatEventCallback {
    func updateInfo(device: DeviceDisplay)
    func newMCTEvent(deviceId: UUID)
}

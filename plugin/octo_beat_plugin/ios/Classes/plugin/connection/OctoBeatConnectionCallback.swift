//
//  OctoBeatConnectionCallback.swift
//  octo_beat_plugin
//
//  Created by TRAN QUANG DAI on 10/02/2023.
//

import Foundation

protocol OctoBeatConnectionCallback {
    func onFoundOctoBeat(devices: [[String: String]])
    func onConnectedOctoBeat(device: [String: String])
    func onConnectFailOctoBeat()
}

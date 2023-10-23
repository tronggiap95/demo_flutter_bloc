//
//  ECGConfig.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 17/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class ECGConfig: NSObject {
    var gain: Double
    var channel: String
    var sampleRate: Int
    
    init(gain: Double, channel: String, sampleRate: Int) {
        self.gain = gain
        self.channel = channel
        self.sampleRate = sampleRate
    }
    
    func convertChannel() -> [CHANNEL] {
        var list = [CHANNEL]()
        switch channel {
        case "1": list.append(CHANNEL.CH_1)
        case "2": list.append(CHANNEL.CH_2)
        case "3": list.append(CHANNEL.CH_3)
        case "12": do {
            list.append(CHANNEL.CH_1)
            list.append(CHANNEL.CH_2)
            }
        case "13": do {
            list.append(CHANNEL.CH_1)
            list.append(CHANNEL.CH_3)
            }
        case "23": do {
            list.append(CHANNEL.CH_2)
            list.append(CHANNEL.CH_3)
            }
        case "123":  do {
            list.append(CHANNEL.CH_1)
            list.append(CHANNEL.CH_2)
            list.append(CHANNEL.CH_3)
            }
        default:
            break
        }
        return list
    }
    
}

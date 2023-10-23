//
//  StreamingECGDataHandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 17/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class StreamingECGDataHandler {
    public static func startStreamingECGData(deviceId: UUID) {
        if let blueHandler =  DeviceManager.sharedInstance.getBlueHandler(deviceId: deviceId) {
            CommandFactory.sendPacket(type: CommandType.REQ_START_STREAM,
                                      params: REQ_START_STREAM_PR(),
                                      blueHandler: blueHandler)
        }
    }
    
    public static func stopStreamingECDData(deviceId: UUID) {
        if let blueHandler =  DeviceManager.sharedInstance.getBlueHandler(deviceId: deviceId) {
            CommandFactory.sendPacket(type: CommandType.REQ_STOP_STREAM,
                                      params: REQ_STOP_STREAM_PR(),
                                      blueHandler: blueHandler)
        }
    }
}

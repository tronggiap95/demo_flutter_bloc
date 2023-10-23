//
//  DeviceHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

public class DeviceHandler {
    static func unPackPacket(packet: Packet, validCount: Int) -> [MessagePackValue]? {
        do {
            let values = try unpackAll(packet.payloadData)
            guard values.count > 0 && values[0].arrayValue?.count ?? 0 >= validCount else {
                return nil
            }
            return values[0].arrayValue
        } catch  {
            return nil
        }
    }
    
    static func getCode(packet: Packet) -> UInt16? {
        if let values = unPackPacket(packet: packet, validCount: 1) {
            return values[0].uint16Value
        }
        return nil
    }
}

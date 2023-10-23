//
//  Packet.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/25/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
enum PacketState {
    case NONE
    case READING_PAYLOAD_SIZE
    case READING_PAYLOAD_DATA
    case READING_CRC
    case FULLED
    
}

class Packet {
    static let MAX_PACKET_LENGTH_IN_BYTES = 3 * 1024
    var status: UInt8!
    var version: UInt8!
    var statusByte: UInt8!
    
    var payloadSizeBuffer: Data!
    var receivedPayloadSize: UInt32!
    var payloadSize: UInt32!
    
    var payloadData: Data!
    var receivedPayloadDataSize: UInt32!
    
    var crc16: Data!
    var receivedCrc16: Int32!
    
    var packetState: PacketState!
    
    public func copy() -> Packet {
        let packet = Packet()
        packet.status = self.status
        
        packet.payloadSizeBuffer = self.payloadSizeBuffer
        packet.receivedPayloadSize = self.receivedPayloadSize
        packet.payloadSize = self.payloadSize
        
        packet.payloadData = self.payloadData
        packet.receivedPayloadDataSize = self.receivedPayloadDataSize
        
        packet.crc16 = self.crc16
        packet.receivedCrc16 = self.receivedCrc16
        
        return packet
    }
}

//
//  CRC16CCITT.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public class CRC16CCITT{
    static func calc(data: [UInt8]) -> Data {
        var crc: UInt16 = 0xFFFF;
        let polynomial: UInt16 = 0x1021;
        
        data.forEach { (byte) in
            crc ^= UInt16(byte) << 8
            (0..<8).forEach({ _ in
                crc = (crc & UInt16(0x8000)) != 0 ? (crc << 1) ^ polynomial : crc << 1
            })
        }
        
        return Data.UInt16ToData(UInt16(crc & 0xFFFF), byteOder: Data.ByteOrder.LittleEndian)
    }
    
    private static func sub(bytes: [UInt8], startPos: Int = 0, endPos: Int) -> [UInt8]{
        let newBytes = Array(bytes[startPos...endPos])
        return newBytes
    }
    
}



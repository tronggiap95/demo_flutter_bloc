
//
//  PacketLengthHelper.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public class PacketLengthHelper {
    public static func encodeLength( len: inout UInt32, buf: inout [UInt8]) -> UInt8{
        var encodeByte, cnt : UInt8
        assert(len <= 0xFFFFFFF)
        cnt = 0
        
        repeat {
            encodeByte = UInt8(len & 0x7F)
            len >>= 7
            encodeByte |= (len != 0) ? 0x80 : 0x00
            cnt += 1
            buf.append(UInt8(encodeByte))
            
        } while(len != 0)
        
        return cnt
    }
    
    public static func decodePakcetLength(buf: [UInt8], size: inout Int) -> UInt32{
        var mutiplier, value: UInt32
        var decodeByte: UInt8
        var cnt = 0
        
        assert(size <= 4)
        assert((buf[size - 1] & 0x80) == 0)
        
        value = 0
        mutiplier = 1
        repeat {
            decodeByte = buf[cnt]
            value += UInt32((decodeByte & 0x7F)) * mutiplier
            mutiplier <<= 7
            cnt += 1
            size -= 1
        } while(size > 0)
        
        return value
    }
}

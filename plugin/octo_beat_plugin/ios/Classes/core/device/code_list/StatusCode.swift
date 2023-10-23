//
//  StatusCode.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/25/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

enum StatusCode {
    case REQUEST
    case RESPONSE
    case NOTIFY
    case KEEPALIVE
    case ACK
    case IGNORE
    case UNKNOWN
    
    public var rawValue: UInt8 {
        switch self {
        case .REQUEST:
            return 0x00
        case .RESPONSE:
            return 0x01
        case .NOTIFY:
            return 0x02
        case .KEEPALIVE:
            return 0x03
        case .ACK:
            return 0x04
        case .IGNORE:
            return 0x2b
        case .UNKNOWN:
            return 0xFF
        }
    }
    
    public static func get(code: UInt8) -> StatusCode{
        switch code {
        case 0x00:
            return .REQUEST
        case 0x01:
            return .RESPONSE
        case 0x02:
            return .NOTIFY
        case 0x03:
            return .KEEPALIVE
        case 0x04:
            return .ACK
        case 0x2b:
            return .IGNORE
        default:
            return .UNKNOWN
        }
    }
}

//
//  ResponseCode.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public enum ResponseCode {
    //Common
    case BB_RSP_OK
    case BB_RSP_ERR_PARAM
    case BB_RSP_ERR_PERMISSION
    case BB_RSP_ERR_OPERATION

    // Request specific
    case BB_RSP_ERR_PACKET_VER
    case BB_RSP_ERR_API_VER
    case BB_RSP_ERR_FULL_DEVICE
    case BB_RSP_ERR_NO_NETWORK
    case BB_RSP_ERR_NOT_PAIRED
    case BB_RSP_ERR_BT_CLASSIC_DENIED
    case BB_RSP_ERR_CONN_TIMEOUT
    case BB_RSP_ERR_CONN_CLOSED
    case BB_RSP_ERR_CONN_OPENED
    
    public var rawValue: UInt16 {
        var value: UInt16 = 0xcccc
        switch self {
        case .BB_RSP_OK:
            value = 0xe000
        case .BB_RSP_ERR_PARAM:
            value = 0xe001
        case .BB_RSP_ERR_PERMISSION:
            value = 0xe002
        case .BB_RSP_ERR_OPERATION:
            value = 0xe003
        case .BB_RSP_ERR_PACKET_VER:
            value = 0xe050
        case .BB_RSP_ERR_API_VER:
            value = 0xe051
        case .BB_RSP_ERR_FULL_DEVICE:
            value = 0xe052
        case .BB_RSP_ERR_NO_NETWORK:
            value = 0xe053
        case .BB_RSP_ERR_NOT_PAIRED:
            value = 0xe054
        case .BB_RSP_ERR_BT_CLASSIC_DENIED:
            value = 0xe055
        case .BB_RSP_ERR_CONN_TIMEOUT:
            value = 0xe100
        case .BB_RSP_ERR_CONN_CLOSED:
            value = 0xe101
        case .BB_RSP_ERR_CONN_OPENED:
            value = 0xe102
        }
        return value
    }
    
    public static func get(value: UInt16) -> ResponseCode?{
         switch value {
         case 0xe000:
            return .BB_RSP_OK
         case 0xe001:
            return .BB_RSP_ERR_PARAM
         case 0xe002:
            return .BB_RSP_ERR_PERMISSION
         case 0xe003:
            return .BB_RSP_ERR_OPERATION
         case 0xe050:
            return .BB_RSP_ERR_PACKET_VER
         case 0xe051:
            return .BB_RSP_ERR_API_VER
         case 0xe052:
            return .BB_RSP_ERR_FULL_DEVICE
         case 0xe053:
            return .BB_RSP_ERR_NO_NETWORK
         case 0xe054:
            return .BB_RSP_ERR_NOT_PAIRED
         case 0xe055:
            return .BB_RSP_ERR_BT_CLASSIC_DENIED
         case 0xe100:
            return .BB_RSP_ERR_CONN_TIMEOUT
         case 0xe101:
            return .BB_RSP_ERR_CONN_CLOSED
         case 0xe102:
            return .BB_RSP_ERR_CONN_OPENED
         default:
            return nil
        }
    }
}

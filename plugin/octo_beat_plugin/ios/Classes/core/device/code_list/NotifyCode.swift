//
//  File.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public enum NotifyCode {
    // Bluetooth
    case BB_NT_ECG_DATA
    case BB_NT_DEVICE_STATUS
    
    // Internet Bridging
    case BB_NT_NETSTAT_UPDATE
    case BB_NT_TCP_TX_DATA
    case BB_NT_TCP_RX_DATA_RDY
    case BB_NT_TCP_CONN_LOST
    case BB_NT_TCP_TX_SPEED
    case BB_NT_TCP_CONN_OPEN_REPORT
    
    public var rawValue: UInt16 {
        var value: UInt16 = 0xcccc
        switch self {
        case .BB_NT_ECG_DATA:
            value = 0xB000
        case .BB_NT_DEVICE_STATUS:
            value = 0xB001
        case .BB_NT_NETSTAT_UPDATE:
            value = 0xB100
        case .BB_NT_TCP_TX_DATA:
            value = 0xB200
        case .BB_NT_TCP_RX_DATA_RDY:
            value = 0xB201
        case .BB_NT_TCP_CONN_LOST:
            value = 0xB202
        case .BB_NT_TCP_TX_SPEED:
            value = 0xB203
        case .BB_NT_TCP_CONN_OPEN_REPORT:
            value = 0xB204
        }
        return value
    }
    
    public static func get(value: UInt16) -> NotifyCode?{
        switch value {
        case 0xB000:
            return .BB_NT_ECG_DATA
        case 0xB001:
            return .BB_NT_DEVICE_STATUS
        case 0xB100:
            return .BB_NT_NETSTAT_UPDATE
        case 0xB200:
            return .BB_NT_TCP_TX_DATA
        case 0xB201:
            return .BB_NT_TCP_RX_DATA_RDY
        case 0xB202:
            return .BB_NT_TCP_CONN_LOST
        case 0xB203:
            return .BB_NT_TCP_TX_SPEED
        default:
            return nil
        }
    }
}

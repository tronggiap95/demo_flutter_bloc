//
//  RequestCode.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public enum RequestCode {
    // REQUEST CODE
    // Common
    case BB_REQ_HANDSHAKE
    case BB_REQ_SWITCH_BT_MODE
    
    // Bluetooth
    case BB_REQ_START_STREAMING_ECG
    case BB_REQ_STOP_STREAMING_ECG
    case BB_REQ_SM_COMMAND
    case BB_REQ_EVENT_TRIGGERED
    case BB_REQ_EVENT_CONFIRMED
    case BB_REQ_GET_TIME
    
    // Internet Bridging
    case BB_REQ_GET_NETSTAT
    case BB_REQ_TCP_OPEN_CONN
    case BB_REQ_TCP_CLOSE_CONN
    case BB_REQ_TCP_GET_CONN_STATUS
    case BB_REQ_TCP_READ_DATA
    case BB_REQ_SSL_SET_CA_CERT
    case BB_REQ_SSL_SET_DEVICE_CERT
    case BB_REQ_SSL_SET_DEVICE_PKEY
    case BB_REQ_SSL_CONN_CONFIG
    
    public var rawValue: UInt16 {
        var value: UInt16 = 0xcccc//INVALID CMD CODE
        switch self {
        case .BB_REQ_HANDSHAKE:
            value =  0xC000
        case .BB_REQ_SWITCH_BT_MODE:
            value =  0xC001
        case .BB_REQ_START_STREAMING_ECG:
            value =  0xC011
        case .BB_REQ_STOP_STREAMING_ECG:
            value =  0xC012
        case .BB_REQ_SM_COMMAND:
            value =  0xC013
        case .BB_REQ_EVENT_TRIGGERED:
            value =  0xC014
        case .BB_REQ_EVENT_CONFIRMED:
            value =  0xC015
        case .BB_REQ_GET_NETSTAT:
            value =  0xC100
        case .BB_REQ_TCP_OPEN_CONN:
            value =  0xC200
        case .BB_REQ_TCP_CLOSE_CONN:
            value =  0xC201
        case .BB_REQ_TCP_GET_CONN_STATUS:
            value =  0xC202
        case .BB_REQ_TCP_READ_DATA:
            value =  0xC203
        case .BB_REQ_SSL_SET_CA_CERT:
            value =  0xC300
        case .BB_REQ_SSL_SET_DEVICE_CERT:
            value =  0xC301
        case .BB_REQ_SSL_SET_DEVICE_PKEY:
            value =  0xC302
        case .BB_REQ_SSL_CONN_CONFIG:
            value =  0xC303
        case .BB_REQ_GET_TIME:
            value = 0xC004
        }
        return value
    }
    
    public static func get(value: UInt16) -> RequestCode?{
        switch value {
        case 0xC000:
            return .BB_REQ_HANDSHAKE
        case 0xC001:
            return .BB_REQ_SWITCH_BT_MODE
        case 0xC011:
            return .BB_REQ_START_STREAMING_ECG
        case 0xC012:
            return .BB_REQ_STOP_STREAMING_ECG
        case 0xC013:
            return .BB_REQ_SM_COMMAND
        case 0xC014:
            return .BB_REQ_EVENT_TRIGGERED
        case 0xC015:
            return .BB_REQ_EVENT_CONFIRMED
        case 0xC100:
            return .BB_REQ_GET_NETSTAT
        case 0xC200:
            return .BB_REQ_TCP_OPEN_CONN
        case 0xC201:
            return .BB_REQ_TCP_CLOSE_CONN
        case 0xC202:
            return .BB_REQ_TCP_GET_CONN_STATUS
        case 0xC203:
            return .BB_REQ_TCP_READ_DATA
        case 0xC300:
            return .BB_REQ_SSL_SET_CA_CERT
        case 0xC301:
            return .BB_REQ_SSL_SET_DEVICE_CERT
        case 0xC302:
            return .BB_REQ_SSL_SET_DEVICE_PKEY
        case 0xC303:
            return .BB_REQ_SSL_CONN_CONFIG
        case 0xC004:
            return .BB_REQ_GET_TIME
        default:
            return nil
        }
    }
}

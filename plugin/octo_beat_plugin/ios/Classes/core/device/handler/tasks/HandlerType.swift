//
//  HandlerType.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/27/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

enum HandlerType {
    case REQ_CLOSE_TCP
    case REQ_CONFIG_SSL
    case REQ_OPEN_TCP
    case REQ_SET_SERVER_CERT
    case REQ_TRIGGER_MCT
    case REQ_HAND_SHAKE
    case REQ_NET_STATUS
    case REQ_READ_TCP_DATA
    case REQ_START_ECG_DATA
    
    case NT_DEVICE_STATUS
    case NT_LOST_TCP
    case NT_NET_CHANGE
    case NT_RECEIVE_TCP_DATA
    case NT_TRANSMIT_DATA
    case NT_TCP_SPEED_TX
    case NT_ECG_DATA
    
    public var description: String {
        switch self {
        case .NT_DEVICE_STATUS:
            return "NT_DEVICE_STATUS"
        case .REQ_CLOSE_TCP:
            return "REQ_CLOSE_TCP"
        case .REQ_CONFIG_SSL:
            return "REQ_CONFIG_SSL"
        case .REQ_OPEN_TCP:
            return "REQ_OPEN_TCP"
        case .REQ_SET_SERVER_CERT:
            return "REQ_SET_SERVER_CERT"
        case .REQ_TRIGGER_MCT:
            return "REQ_TRIGGER_MCT"
        case .REQ_HAND_SHAKE:
            return "REQ_HAND_SHAKE"
        case .REQ_NET_STATUS:
            return "REQ_NET_STATUS"
        case .REQ_READ_TCP_DATA:
            return "REQ_READ_TCP_DATA"
        case .REQ_START_ECG_DATA:
            return "REQ_START_ECG_DATA"
        case .NT_LOST_TCP:
            return "NT_LOST_TCP"
        case .NT_NET_CHANGE:
            return "NT_NET_CHANGE"
        case .NT_RECEIVE_TCP_DATA:
            return "NT_RECEIVE_TCP_DATA"
        case .NT_TRANSMIT_DATA:
            return "NT_TRANSMIT_DATA"
        case .NT_TCP_SPEED_TX:
            return "NT_TCP_SPEED_TX"
        case .NT_ECG_DATA:
            return "NT_ECG_DATA"
        }
    }
    
}

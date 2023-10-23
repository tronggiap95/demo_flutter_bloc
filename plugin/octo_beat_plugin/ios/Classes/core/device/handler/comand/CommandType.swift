//
//  CommandType.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

public enum CommandType {
    case NT_NET_CHANGE
    case NT_LOST_TCP_CONN
    case NT_RECEIVE_TCP_DATA
    case NT_TCP_SPEED_TX
    case BB_NT_TCP_CONN_OPEN_REPORT
    case RSP_CLOSE_TCP
    case RSP_CONFIG_SSL
    case RSP_HANDSHAKE
    case RSP_TRGGER_MCT
    case RSP_NET_STATUS
    case RSP_OPEN_TCP
    case RSP_READ_TCP
    case RSP_SET_SERVER_CER
    case RSP_GET_TIME
    
    case REQ_START_STREAM
    case REQ_STOP_STREAM
    case REQ_CONFIRM_MCT
    case REQ_SW_MODE
}

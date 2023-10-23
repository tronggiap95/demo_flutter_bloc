//
//  CommandFactory.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class CommandFactory {
    private static let TAG = "CommandFactory"
    private static func get(type: CommandType) -> Command{
        switch type {
        case .NT_NET_CHANGE:
            return NT_NetStatusChange()
        case .NT_LOST_TCP_CONN:
            return NT_LostTCPConnection()
        case .NT_RECEIVE_TCP_DATA:
            return NT_ReceiveTCPData()
        case .NT_TCP_SPEED_TX:
            return NT_TCPSpeedTX()
        case .BB_NT_TCP_CONN_OPEN_REPORT:
            return NT_TCPOpen()
        case .RSP_CLOSE_TCP:
            return RSP_CloseTCP()
        case .RSP_CONFIG_SSL:
            return RSP_ConfigureSSL()
        case .RSP_HANDSHAKE:
            return RSP_HandShake()
        case .RSP_TRGGER_MCT:
            return RSP_TriggerMCT()
        case .RSP_NET_STATUS:
            return RSP_NetStatus()
        case .RSP_OPEN_TCP:
            return RSP_OpenTCP()
        case .RSP_READ_TCP:
            return RSP_ReadTCPData()
        case .RSP_SET_SERVER_CER:
            return RSP_SetServerCer()
        case .REQ_START_STREAM:
            return REQ_StartStreammingECG()
        case .REQ_STOP_STREAM:
            return REQ_StopStreammingECG()
        case .REQ_CONFIRM_MCT:
            return REQ_ConfirmMCT()
        case .REQ_SW_MODE:
            return REQ_SWmode()
        case .RSP_GET_TIME:
             return RSP_GetTime()
        }
    }
    
    static func sendPacket(type: CommandType, params: CommandParams, blueHandler: BluetoothHandler?){
        LogUtil.myLogInfo(clazz: TAG, methodName: "buildPacket", message: "\(type)")
        let command = get(type: type)
        params.ase = blueHandler?.aes
        params.isSecure = blueHandler?.isSecure() ?? false
        let data = (command.setSecure(isSecure: params.isSecure, aes: params.ase).build?(params: params).getData())
        if let data = data {
            blueHandler?.send(data: data)
        }
    }
}

//
//  DeviceHandlerFactory.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/27/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack

class DeviceHandlerFactory: DeviceHandler {
    private static let TAG = "DEVICE_HANDLER_FACTORY"

    private static func notifyHandler(packet: Packet, bluetoothHandler: BluetoothHandler, socketHandler: SocketHandler, callback: DXHDeviceHandlerCallback?) {
        let code = getCode(packet: packet)
        guard code != nil else {
            return
        }
        
        let notifyCode = NotifyCode.get(value: code!)
        
        guard notifyCode != nil else {
            return
        }
        
        switch notifyCode! {
        case .BB_NT_DEVICE_STATUS:
            NotifyDeviceStatushandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_NT_NETSTAT_UPDATE:
            NotifyNetChangeHandler.handle(socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_NT_TCP_TX_DATA:
            NotifyTransmitDataHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_NT_TCP_RX_DATA_RDY:
            NotifyReceiveTCPHandler.handle(blueHandler: bluetoothHandler, dataLength: packet.payloadData.count, callback: callback)
            break
        case .BB_NT_TCP_CONN_LOST:
            NotifyLostTCPHandler.handle(blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_NT_ECG_DATA:
            NotifyECGDataHandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_NT_TCP_TX_SPEED:
            break
        default: break
        }
    }
    
    private static func requestHandler(packet: Packet, bluetoothHandler: BluetoothHandler, socketHandler: SocketHandler, callback: DXHDeviceHandlerCallback?) {
        let code = getCode(packet: packet)
        guard code != nil else {
            return
        }
        
        let requestCode = RequestCode.get(value: code!)
        
        guard requestCode != nil else {
            return
        }
        
        switch requestCode! {
        case .BB_REQ_TCP_OPEN_CONN:
            OpenTCPHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_TCP_CLOSE_CONN:
            CloseTCPHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_HANDSHAKE:
            HandShakeHandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_EVENT_TRIGGERED:
            TriggerMCTHandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_EVENT_CONFIRMED:
            //Not handle yet
            break
        case .BB_REQ_GET_NETSTAT:
            NetStatusHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_TCP_READ_DATA:
            ReadTCPDataHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_SSL_SET_CA_CERT:
            SetServerCerHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
        case .BB_REQ_SSL_CONN_CONFIG:
            ConfigSSLHandler.handle(packet: packet, socketHandler: socketHandler, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_GET_TIME:
            GetTimehandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        case .BB_REQ_TCP_GET_CONN_STATUS:
            //TO DO
            break
        case .BB_REQ_SSL_SET_DEVICE_CERT:
            //TO DO
            break
        case .BB_REQ_SSL_SET_DEVICE_PKEY:
            //TO DO
            break
        case .BB_REQ_SWITCH_BT_MODE:
            //TO DO
            break
        case .BB_REQ_START_STREAMING_ECG:
            //TO DO
            break
        case .BB_REQ_STOP_STREAMING_ECG:
            //TO DO
            break
        case .BB_REQ_SM_COMMAND:
            //TO DO
            break
        }
    }
    
    private static func responseForRequestHandler(packet: Packet, bluetoothHandler: BluetoothHandler, socketHandler: SocketHandler, callback: DXHDeviceHandlerCallback?) {
        let code = getCode(packet: packet)
        guard code != nil else {
            return
        }
        
        let requestCode = RequestCode.get(value: code!)
        
        guard requestCode != nil else {
            return
        }
        
        switch requestCode! {
        case .BB_REQ_START_STREAMING_ECG:
            ConfigECGHandler.handle(packet: packet, blueHandler: bluetoothHandler, callback: callback)
            break
        default:
            break
        }
    }
    
    
    static func handlePacket(packet: Packet, bluetoothHandler: BluetoothHandler, socketHandler: SocketHandler, callback: DXHDeviceHandlerCallback?) {
        let statusCode = StatusCode.get(code: packet.status)
        switch statusCode {
        case .REQUEST:
            requestHandler(packet: packet, bluetoothHandler: bluetoothHandler, socketHandler: socketHandler, callback: callback)
            break
        case .NOTIFY:
            notifyHandler(packet: packet, bluetoothHandler: bluetoothHandler, socketHandler: socketHandler, callback: callback)
            break
        case .RESPONSE:
            responseForRequestHandler(packet: packet, bluetoothHandler: bluetoothHandler, socketHandler: socketHandler, callback: callback)
        default:
            break
        }
    }
}

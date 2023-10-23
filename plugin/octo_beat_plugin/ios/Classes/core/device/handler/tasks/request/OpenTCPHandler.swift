//
//  OpenTCPHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class OpenTCPHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(socketHandler: socketHandler, bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        if let values = unPackPacket(packet: packet, validCount: 6) {
            if let connectionId = values[1].uint8Value,
                let address = values[2].stringValue,
                let port = values[3].intValue,
                let connectionTimeout = values[4].uint8Value,
                let isSSLEnabled = values[5].boolValue {
                let tcpConnection = socketHandler.getTCPConnection(id: connectionId)
                let serverCA = socketHandler.serverCA[connectionId]
                
                if(tcpConnection != nil && isSSLEnabled && serverCA != nil) {
                    tcpConnection?.isSSLEnable = true
                    if blueHandler.apiVersion > 4 {
                        CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                                  params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_OK),
                                                  blueHandler: blueHandler)
                    }
                    socketHandler.startConection(ip: address, port: UInt16(port), certificate: serverCA!, timeout: Double(connectionTimeout))
                }
            }
        }
    }
    
    public static func handleConnected(bluetoothHandler: BluetoothHandler?) {
        if bluetoothHandler?.apiVersion ?? 0 > 4 {
            NotifyTCPOpenHandler.handle(param: NT_TCP_OPEN_PR(connectionId: 1, isConnected: true), blueHandler: bluetoothHandler)
        } else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_OK),
                                      blueHandler: bluetoothHandler)
        }
    }
    
    public static func handleTimeout(bluetoothHandler: BluetoothHandler?) {
        if bluetoothHandler?.apiVersion ?? 0 > 4 {
            NotifyTCPOpenHandler.handle(param: NT_TCP_OPEN_PR(connectionId: 1, isConnected: false), blueHandler: bluetoothHandler)
        } else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_CONN_TIMEOUT),
                                      blueHandler: bluetoothHandler!)
        }
    }
    
    private static func isResponseFailed(socketHandler: SocketHandler, bluetoothHandler: BluetoothHandler, packet: Packet) -> Bool {
        guard bluetoothHandler.isConnected else {
            return true
        }
        
        guard bluetoothHandler.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard socketHandler.isNetworkAvailable() else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_NO_NETWORK),
                                      blueHandler: bluetoothHandler)
            return true        }
        
        guard !socketHandler.isOpened else {
            CommandFactory.sendPacket(type: CommandType.RSP_OPEN_TCP,
                                      params: RSP_OPEN_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_CONN_OPENED),
                                      blueHandler: bluetoothHandler)
            return true        }
        
        return false
    }
}

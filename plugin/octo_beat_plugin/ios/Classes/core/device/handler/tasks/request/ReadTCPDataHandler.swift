//
//  ReadTCPDataHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation


class ReadTCPDataHandler: RequestHandler {
    public static func handle(packet: Packet, socketHandler: SocketHandler, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(socketHandler: socketHandler, bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if let values = unPackPacket(packet: packet, validCount: 3) {
            if  let connectionId = values[1].uint8Value,
                let length = values[2].intValue {
                self.sendTCPData(socketHandler: socketHandler, bluetoothHandler: blueHandler, length: length)
                if(socketHandler.takeDataLength() > 0) {
                    NotifyReceiveTCPHandler.handle(blueHandler: blueHandler, dataLength: length, callback: callback)
                }
            }
            
        }
    }
    
    private static func sendTCPData(socketHandler: SocketHandler?, bluetoothHandler: BluetoothHandler?,  length: Int?) {
        guard length != nil else {
            return
        }
        
        let dataTCP = socketHandler?.readData(socketHandler: socketHandler, length: length!)
        if(dataTCP == nil) {
            return
        }
        socketHandler?.putDataLength(length: socketHandler!.takeDataLength() - dataTCP!.count)
        CommandFactory.sendPacket(type: CommandType.RSP_READ_TCP,
                                  params: RSP_READ_TCP_PR(responseCode: ResponseCode.BB_RSP_OK, bytes: dataTCP!),
                                  blueHandler: bluetoothHandler)
    }
    
    private static func isResponseFailed(socketHandler: SocketHandler?, bluetoothHandler: BluetoothHandler?, packet: Packet) -> Bool {
        guard bluetoothHandler!.isConnected else {
            return true
        }
        
        guard bluetoothHandler!.isHandshaked else {
            CommandFactory.sendPacket(type: CommandType.RSP_READ_TCP,
                                      params: RSP_READ_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PERMISSION, bytes: Data()),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard !isInvalidParams(packet: packet) else {
            CommandFactory.sendPacket(type: CommandType.RSP_READ_TCP,
                                      params: RSP_READ_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_PARAM, bytes: Data()),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        guard socketHandler!.isOpened else {
            CommandFactory.sendPacket(type: CommandType.RSP_READ_TCP,
                                      params: RSP_READ_TCP_PR(responseCode: ResponseCode.BB_RSP_ERR_CONN_CLOSED, bytes: Data()),
                                      blueHandler: bluetoothHandler)
            return true
        }
        
        return false
    }
}

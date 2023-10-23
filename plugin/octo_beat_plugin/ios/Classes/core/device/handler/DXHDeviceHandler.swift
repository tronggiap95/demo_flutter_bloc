//
//  DXHDeviceHandler.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/20/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
protocol DXHDeviceHandlerCallback {
    func updateDeviceStatus(deviceStatus: DeviceStatus, bluetoothHandler: BluetoothHandler?)
    func eventMCTTrigger(time: Int, bluetoothHandler: BluetoothHandler?)
    func handShakeDone(handshakePR: REQ_HANDSHAKE_PR, bluetoothHandler: BluetoothHandler?)
    func notifyTCPStatus(connected: Bool, bluetoothHandler: BluetoothHandler?)
    func errorPacketParser(bluetoothHandler: BluetoothHandler?)
    func updateTx(size: Int64, bluetoothHandler: BluetoothHandler?)
    func updateRx(size: Int64, bluetoothHandler: BluetoothHandler?)
    func updateECGData(data: Data, bluetoothHandler: BluetoothHandler?)
    func updateECGConfig(ecgConfig: ECGConfig, bluetoothHandler: BluetoothHandler?)
}

class DXHDeviceHandler {
    private let TAG = "DXH_DEVICE_HANDLER"
    var bluetoothHandler: BluetoothHandler?
    var socketHandler: SocketHandler?
    
    private var packetParser: PacketParser?
    
    private var stopHandler = false
    private var thread:Thread?
    
    private var callback: DXHDeviceHandlerCallback?
    
    var identify: UUID?
    var name: String?
    
    init(bluetoothHandler: BluetoothHandler?, callback: DXHDeviceHandlerCallback?){
        self.bluetoothHandler = bluetoothHandler
        self.bluetoothHandler?.registerCallback(self)
        self.callback = callback
        
        self.identify = bluetoothHandler?.deviceId
        self.name = bluetoothHandler?.deviceName
        
        self.socketHandler = SocketHandler(callback: self)
        self.packetParser = PacketParser(bluetoothHandler: bluetoothHandler, callback: self)
        self.packetParser?.start()
        // self.start()
    }
    
    public func sendBle(data: Data) {
        bluetoothHandler?.send(data: data)
    }
    
    public func sendSock(data: Data) {
        _ = socketHandler?.send(data: data)
    }
    
    public func forceStop() {
        packetParser?.stop()
        stopHandler = true
        thread?.cancel()
        thread = nil
        bluetoothHandler?.forcedClose()
        socketHandler?.forcedClose()
    }
    
    private func start() {
        thread = Thread.init(target: self, selector: #selector(longHandlerProcess), object: nil)
        thread?.start()
    }
    
    @objc private func longHandlerProcess() {
        while(!self.stopHandler) {
            if let packet = self.packetParser?.packets.first {
                self.handlePacketBluetooth(packet: packet!)
            }
        }
    }
    
    private func handlePacketBluetooth(packet: Packet) {
        if let bluetoothHandler = self.bluetoothHandler, let socketHandler = self.socketHandler {
            DeviceHandlerFactory.handlePacket(packet: packet, bluetoothHandler: bluetoothHandler, socketHandler: socketHandler, callback: callback)
        }
    }
}

extension DXHDeviceHandler:  PacketParserCallback {
    func newPacket(packet: Packet) {
        self.handlePacketBluetooth(packet: packet)
    }
    
    public func closeAndReconnect() {
        packetParser?.stop()
        stopHandler = true
        thread?.cancel()
        thread = nil
        self.socketHandler?.close()
        self.bluetoothHandler?.close()
        self.bluetoothHandler?.isAutoReconnect = true
    }
    
    func receivedPacketIncorrectCRC(bluetoothHandler: BluetoothHandler?) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "PACKET_PARSER_ERROR", message: "INVALID CRC")
        self.callback?.errorPacketParser(bluetoothHandler: bluetoothHandler)
        self.closeAndReconnect()
    }
    
    func receivedInvalidStatusCode(bluetoothHandler: BluetoothHandler?) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "PACKET_PARSER_ERROR", message: "INVALID STATUS CODE")
        self.callback?.errorPacketParser(bluetoothHandler: bluetoothHandler)
        self.closeAndReconnect()
    }
    
    func receivedInvalidPacketLength(bluetoothHandler: BluetoothHandler?) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "PACKET_PARSER_ERROR", message: "INVALID PACKET LENGTH")
        self.callback?.errorPacketParser(bluetoothHandler: bluetoothHandler)
        self.closeAndReconnect()
    }
    
    func receivedTimeOut(bluetoothHandler: BluetoothHandler?) {
        LogUtil.myLogInfo(clazz: TAG, methodName: "PACKET_PARSER_ERROR", message: "TIME OUT")
        self.callback?.errorPacketParser(bluetoothHandler: bluetoothHandler)
        self.closeAndReconnect()
    }
    
}


extension DXHDeviceHandler: SocketHandlerCallback {
    func didConnected() {
        OpenTCPHandler.handleConnected(bluetoothHandler: self.bluetoothHandler)
        callback?.notifyTCPStatus(connected: true, bluetoothHandler: self.bluetoothHandler)
        
    }
    
    func didLostConnection() {
        callback?.notifyTCPStatus(connected: false, bluetoothHandler: self.bluetoothHandler)
        if let bluetoothHandler = self.bluetoothHandler {
            NotifyLostTCPHandler.handle(blueHandler: bluetoothHandler, callback: callback)
        }
    }
    
    func didReceiveData(data: Data) {
        if let bluetoothHandler = self.bluetoothHandler {
            NotifyReceiveTCPHandler.handle(blueHandler: bluetoothHandler, dataLength: data.count, callback: callback)
        }
    }
    
    func didConnectFailed() {
        callback?.notifyTCPStatus(connected: false, bluetoothHandler: self.bluetoothHandler)
       if let bluetoothHandler = self.bluetoothHandler {
        OpenTCPHandler.handleTimeout(bluetoothHandler: bluetoothHandler)
       }
    }
    
    func updateRx(size: Int64) {
        callback?.updateRx(size: size, bluetoothHandler: bluetoothHandler)
    }
    
    func updateTx(size: Int64) {
        callback?.updateTx(size: size, bluetoothHandler: bluetoothHandler)
    }
}

extension DXHDeviceHandler: BluetoothHandlerCallback {
    func onConnected(bluetoothHandler: BluetoothHandler) {
        
    }
    
    func onConnectedFailed(bluetoothHandler: BluetoothHandler) {
        
    }
    
    func onDisconnected(bluetoothHandler: BluetoothHandler) {
        self.forceStop()
    }
    
    
}

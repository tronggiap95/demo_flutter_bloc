//
//  PacketParser.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/25/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

protocol PacketParserCallback {
    func receivedPacketIncorrectCRC(bluetoothHandler: BluetoothHandler?)
    func receivedInvalidStatusCode(bluetoothHandler: BluetoothHandler?)
    func receivedInvalidPacketLength(bluetoothHandler: BluetoothHandler?)
    func receivedTimeOut(bluetoothHandler: BluetoothHandler?)
    func newPacket(packet: Packet)
}

class PacketParser {
    private let TAG = "PACKET_PARSER"
    private var TAG_DEBUG = ""
    
    private var mPacket: Packet?
    var packets = SynchronizedArray<Packet?>()
    
    private var bluetoothHandler: BluetoothHandler?
    private var callback: PacketParserCallback?
    
    private var isSendingLowCapacity = false
    
    var stopParser = false
    var thread: Thread?
    
    
    init(bluetoothHandler: BluetoothHandler?, callback: PacketParserCallback?) {
        self.bluetoothHandler = bluetoothHandler
        self.callback = callback
        TAG_DEBUG = "DEBUG LOG ID-\(bluetoothHandler?.deviceName ?? "nil") "
    }
    
    func stop() {
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "STOP_PACKET_PARSER")
        stopParser = true
        thread?.cancel()
        packets.removeAll()
        thread = nil
    }
    
    func start() {
        thread = Thread.init(target: self, selector: #selector(longParserRunningProcess), object: nil)
        thread?.start()
    }
    
    @objc private func longParserRunningProcess() {
        while(!self.stopParser) {
            self.handleLowBufferCapacity()
            let data = try? self.bluetoothHandler?.datas.take()
            if let data = data {
                self.parse(data: data, currentPacket: &self.mPacket)
            }
        }
    }
    
    private func handleLowBufferCapacity() {
        if let bluetoothHandler = self.bluetoothHandler {
            if(bluetoothHandler.isHandshaked && bluetoothHandler.apiVersion > 1){
                if(bluetoothHandler.datas.count() > 100 && !isSendingLowCapacity){
                    NotifyTCPSpeedTXHandler.handle(blueHandler: bluetoothHandler, param: NT_TCP_SPEED_TX_PR(connectionId: 1, speed: 1), callback: nil)
                    isSendingLowCapacity = true
                } else if(bluetoothHandler.datas.count() < 3 && isSendingLowCapacity) {
                    NotifyTCPSpeedTXHandler.handle(blueHandler: bluetoothHandler, param: NT_TCP_SPEED_TX_PR(connectionId: 1, speed: 0), callback: nil)
                    
                    isSendingLowCapacity = false
                }
            }
        }
    }
    
    func parse(data: Data?, currentPacket: inout Packet?){
        if(data == nil || data?.count == 0){
            //  mPacket = currentPacket
            return
        }
        
        if(currentPacket == nil){
            currentPacket = Packet()
            currentPacket?.packetState = PacketState.NONE
        }
        
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "=======+++++++++coming data+++++++++++=====")
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "=======+++++++++coming data+++++++++++=====")
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "NEW DATA LENGTH PARSER: \(data!.count)")
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "NEW DATA LENGTH PARSER: \(data!.toHexString())")
        
        var buffer = data
        var done = false
        
        while(!done && (buffer != nil && buffer!.count > 0)) {
            LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message:"state = \(currentPacket?.packetState ?? PacketState.NONE)")
            switch(currentPacket!.packetState!){
            case .NONE:
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "==================================+++++++++parse+++++++++++=============================")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "NONE - READ STATUS")
                buffer = parseStatus(buffer: &buffer, packet: &currentPacket!)
                break
            case .READING_PAYLOAD_SIZE:
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_SIZE")
                buffer = parsePayloadSize(buffer: &buffer, packet: &currentPacket!)
                break
            case .READING_PAYLOAD_DATA:
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_DATA")
                buffer = parsePayloadData(buffer: &buffer, packet: &currentPacket!)
                break
            case .READING_CRC:
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_CRC")
                buffer = parseCRC(buffer: &buffer, packet: &currentPacket!)
                
                if(currentPacket?.receivedCrc16 == 2) {
                    crcDoneHandler(currentPacket: &currentPacket!)
                    done = true
                    currentPacket  = nil
                }
                
                break
            case .FULLED:
                break
            }
        }
        
        parse(data: buffer, currentPacket: &currentPacket)
        
    }
    
    private func crcDoneHandler(currentPacket: inout Packet) {
        let b1 = currentPacket.statusByte!
        let b2 = currentPacket.payloadSizeBuffer.subArray(in: 0...Int(currentPacket.receivedPayloadSize))!
        let b3 = currentPacket.payloadData!
        let b4 = currentPacket.crc16!
        if(checkCRC(status: b1, payloadSize: b2, payloadData: b3, receivedCRC: b4)) {
            if currentPacket.version > 0 {
                let payloadDecrypt = bluetoothHandler?.aes?.decrypt(bytes: currentPacket.payloadData.toByteBuffer())
                LogUtil.myLogInfo(clazz: TAG, methodName: "crcDoneHandler", message: payloadDecrypt?.toHexString() ?? "")
                if payloadDecrypt != nil {
                    currentPacket.payloadData = Data.init(bytes: payloadDecrypt!)
                } else {
                    self.stopParser = true
                    self.callback?.receivedPacketIncorrectCRC(bluetoothHandler: self.bluetoothHandler)
                    return
                }
            }
            callback?.newPacket(packet: currentPacket.copy())
            // packets.append(currentPacket?.copy())
        } else {
            self.stopParser = true
            self.callback?.receivedPacketIncorrectCRC(bluetoothHandler: self.bluetoothHandler)
        }
    }
    
    
    private func parseStatus(buffer: inout Data?, packet: inout Packet) -> Data?{
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_STATUS: buffer = \(buffer!.toHexString())")
        guard buffer != nil else {
            return nil
        }
        let statusCode = buffer![0] & 0x0f;
        let version = (buffer![0] & 0xf0) >> 4
        
        if(StatusCode.get(code: statusCode) == StatusCode.UNKNOWN){
            self.stopParser = true
            self.callback?.receivedInvalidStatusCode(bluetoothHandler: self.bluetoothHandler)
        }
        
        if(statusCode == StatusCode.IGNORE.rawValue){
            buffer = buffer!.subArray(in: 1...buffer!.count)
            return buffer
        }
        
        packet.status = statusCode
        packet.version = version
        packet.statusByte = buffer![0] & 0xff
        packet.packetState = PacketState.READING_PAYLOAD_SIZE
        buffer = buffer!.subArray(in: 1...buffer!.count)
        bluetoothHandler?.protoVersion = Int(version)
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "NONE-READ STATUS: DONE  = \(String(describing: packet.status!))")
        
        return buffer
    }
    
    private func parsePayloadSize(buffer: inout Data?, packet: inout Packet) -> Data?{
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_SIZE: buffer = \(buffer!.toHexString())")
        repeat {
            let b: UInt8 = buffer![0]
            buffer = buffer!.subArray(in: 1...buffer!.count)
            if(packet.payloadSizeBuffer == nil) {
                packet.payloadSizeBuffer = Data()
                packet.receivedPayloadSize = 0
            }
            packet.payloadSizeBuffer?.append(b)
            packet.receivedPayloadSize += 1
            
            if((b & 0x80) == 0x00){
                let tmp = packet.payloadSizeBuffer?.subArray(in: 0...Int(packet.receivedPayloadSize!))
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_SIZE: tmp = \(tmp?.toHexString() ?? "nil")")
                var size = Int(packet.receivedPayloadSize & 0xff)
                packet.payloadSize = PacketLengthHelper.decodePakcetLength(buf: tmp!.array, size: &size)
                packet.packetState = PacketState.READING_PAYLOAD_DATA
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_SIZE: DONE \(packet.payloadSize!)")
                
                if(packet.payloadSize > Packet.MAX_PACKET_LENGTH_IN_BYTES) {
                    LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "receivedInvalidPacketLength: \(packet.payloadSize!)")
                    self.stopParser = true
                    self.callback?.receivedInvalidPacketLength(bluetoothHandler: self.bluetoothHandler)
                }
                
                break
            } else if(packet.receivedPayloadSize == 4){
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "receivedInvalidPacketLength: \(packet.payloadSize!)")
                self.stopParser = true
                self.callback?.receivedInvalidPacketLength(bluetoothHandler: self.bluetoothHandler)
                break
            } else {
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_SIZE: NOT DONE YET \(packet.receivedPayloadSize!)")
            }
            
        } while (buffer != nil && buffer!.count > 0)
        
        return buffer
    }
    
    private func parsePayloadData(buffer: inout Data?, packet: inout Packet) -> Data? {
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_DATA: buffer = \(buffer!.toHexString())")
        if(packet.receivedPayloadDataSize == nil){
            packet.receivedPayloadDataSize = 0
        }
        let size = packet.payloadSize - packet.receivedPayloadDataSize
        let b1 = buffer?.subArray(in: 0...Int(size))
        if(b1 == nil) {
            return nil
        }
        
        if(packet.payloadData == nil) {
            packet.payloadData = b1
        } else {
            packet.payloadData.append(b1!)
        }
        
        buffer = buffer?.subArray(in: b1!.count...buffer!.count)
        
        if(buffer == nil || UInt32(buffer!.count) <= packet.payloadSize) {
            packet.receivedPayloadDataSize += UInt32(b1!.count)
        } else {
            packet.receivedPayloadDataSize += packet.payloadSize - packet.receivedPayloadDataSize
        }
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_DATA: PROCESS - \(String(describing: packet.receivedPayloadDataSize!))/\(String(describing: packet.payloadSize!))")
        
        if(packet.receivedPayloadDataSize == packet.payloadSize) {
            LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_DATA: DONE - \(packet.payloadData.toHexString())")
            packet.packetState = PacketState.READING_CRC
        } else if(packet.receivedPayloadDataSize > packet.payloadSize) {
            LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "receivedPayloadDataSize > receivedPayloadSize: \(String(describing: packet.receivedPayloadDataSize))/\(String(describing: packet.payloadSize))")
            assert(true)
        }
        
        
        return buffer
    }
    
    
    private func parseCRC(buffer: inout Data?, packet: inout Packet) -> Data? {
        LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_PAYLOAD_CRC: buffer = \(buffer!.toHexString())")
        if(packet.crc16 == nil) {
            packet.crc16 = Data()
            packet.receivedCrc16 = 0
        }
        
        repeat {
            let b = buffer![0]
            buffer = buffer?.subArray(in: 1...buffer!.count)
            
            packet.crc16.append(b)
            packet.receivedCrc16 += 1
            
            if(packet.receivedCrc16 == 2) {
                packet.packetState = PacketState.FULLED
                
                //LOG DEBUG
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_CRC: DONE")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "------------------------FINISH-----------------------")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "------------------------FINISH-----------------------")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "STATUS: \(packet.status!)")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "PAYLOAD SIZE BUFFER: \(packet.payloadSizeBuffer.toHexString())")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "PAYLOAD DATA: \(packet.payloadData.toHexString())")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "CRC: \(packet.crc16.toHexString())")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message:
                    "----------------------NEXT PACKET--------------------")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "")
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "")
                //END
                
                break
            } else {
                LogUtil.myLogInfo(clazz: TAG, methodName: TAG_DEBUG, message: "READING_CRC: NOT DONE YET- \(packet.crc16.toHexString())")
            }
        } while (buffer != nil && buffer!.count > 0)
        
        return buffer
    }
    
    private func checkCRC(status: UInt8, payloadSize: Data, payloadData: Data,receivedCRC: Data) -> Bool {
        var data = Data()
        data.append(status)
        data.append(payloadSize)
        data.append(payloadData)
        
        let crc = CRC16CCITT.calc(data: data.array)
        
        return receivedCRC == crc
    }
    
}

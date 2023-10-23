//
//  NotifyECGDataHandler.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 17/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

enum CHANNEL: String {
    case CH_1
    case CH_2
    case CH_3
}

class NotifyECGDataHandler: NotifyHandler {
    public static func handle(packet: Packet, blueHandler: BluetoothHandler, callback: DXHDeviceHandlerCallback?) {
        
        guard !isResponseFailed(bluetoothHandler: blueHandler, packet: packet) else {
            return
        }
        
        if  let values = unPackPacket(packet: packet, validCount: 3) {
            //        let index = unpackValue?.values[1].uintValue
            if let data = (values[2].dataValue) {
                callback?.updateECGData(data: data, bluetoothHandler: blueHandler)
            }
        }
    }
    
    public static func parseECGSample(ECGConfig: ECGConfig, data: Data) -> ECGSample? {
        let channels = ECGConfig.convertChannel()
        let gain = ECGConfig.gain
        switch channels.count {
        case 1:
            return parseOneChannel(channels: channels, gain: gain, data: data)
        case 2:
            return parseTwoChannels(channels: channels, gain: gain, data: data)
        case 3:
            return parseThreeChannels(channels: channels, gain: gain, data: data)
        default:
            return nil
        }
    }
    
    private static func isResponseFailed(bluetoothHandler: BluetoothHandler?, packet: Packet) -> Bool {
        guard bluetoothHandler!.isConnected else {
            return true
        }
        return false
    }
    
    private static func parseOneChannel(channels: [CHANNEL], gain: Double, data: Data) -> ECGSample? {
        var ch = [Int16]()
        for i in stride(from: 0, to: data.count, by: 2) {
            let sample = data.sub(in: i...i+2)
            guard let value = sample?.toInt16(byteOrder: .LittleEndian) else { return nil}
            ch.append(value)
        }
        
        switch channels[0] {
        case .CH_1:
            return ECGSample(ch1: ch, ch2: nil, ch3: nil)
        case .CH_2:
            return ECGSample(ch1: ch, ch2: nil, ch3: nil)
        case .CH_3:
            return ECGSample(ch1: ch, ch2: nil, ch3: nil)
        }
    }
    
    private static func parseTwoChannels(channels: [CHANNEL], gain: Double, data: Data) -> ECGSample? {
        var data1 = [Int16]()
        var data2 = [Int16]()
        for i in stride(from: 0, to: data.count, by: 4) {
            let sample1 = data.sub(in: i...i+2)
            let sample2 = data.sub(in: i+2...i+4)
            guard let value1 = sample1?.toInt16(byteOrder: .LittleEndian) else { return nil}
            guard let value2 = sample2?.toInt16(byteOrder: .LittleEndian) else { return nil}
            data1.append(value1)
            data2.append(value2)
        }
        let chValue1 = channels[0]
        let chValue2 = channels[1]
        if(chValue1 == .CH_1 && chValue2 == .CH_2) {
            return ECGSample(ch1: data1, ch2: data2, ch3: nil)
        } else if (chValue1 == .CH_1 && chValue2 == .CH_3) {
            return ECGSample(ch1: data1, ch2: nil, ch3: data2)
        } else {
            return ECGSample(ch1: nil, ch2: data1, ch3: data2)
        }
    }
    
    private static func parseThreeChannels(channels: [CHANNEL], gain: Double, data: Data) -> ECGSample? {
        var data1 = [Int16]()
        var data2 = [Int16]()
        var data3 = [Int16]()
        for i in stride(from: 0, to: data.count, by: 6) {
            let sample1 = data.sub(in: i...i+2)
            let sample2 = data.sub(in: i+2...i+4)
            let sample3 = data.sub(in: i+4...i+6)
            guard let value1 = sample1?.toInt16(byteOrder: .LittleEndian) else { return nil}
            guard let value2 = sample2?.toInt16(byteOrder: .LittleEndian) else { return nil}
            guard let value3 = sample3?.toInt16(byteOrder: .LittleEndian) else { return nil}
            data1.append(value1)
            data2.append(value2)
            data3.append(value3)
        }
        return ECGSample(ch1: data1, ch2: data2, ch3: data3)
    }
    
}

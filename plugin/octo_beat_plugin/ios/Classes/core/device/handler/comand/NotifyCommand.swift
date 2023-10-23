//
//  NotifyCommand.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
class NotifyCommand: Command {
    private var data: Data?
    private var isSecure: Bool = false
    private var aes: AESManager?
    
    func getData() -> Data? {
        return data
    }
    
    func setSecure(isSecure: Bool, aes: AESManager?) -> Command {
        self.isSecure = isSecure
        self.aes = aes
        return self
    }
    
    //PACKET FORMATER: build packet: [status:payloadsize:payloadData:crc]
    func buildPacket(payloadData: Data) -> Command {
        let status:UInt8 = 0x02;
        let version: UInt8 = 0x10;

        if(isSecure) {
            let payloadSecure = aes?.encrypt(data: payloadData.toByteBuffer())
            if let payload = payloadSecure {
                data = Data()
                //build payload size array
                var array = [UInt8]()
                var length = UInt32(payload.count)
                let count = PacketLengthHelper.encodeLength(len: &length, buf: &array)
                let payloadSize = array[0..<Int(count)]
                
                //build packet: [status:payloadsize:payloadData]
                data?.append(status + version)
                data?.append(contentsOf: payloadSize)
                data?.append(contentsOf: payload)
            }
        } else {
            data = Data()
            //build payload size array
            var array = [UInt8]()
            var length = UInt32(payloadData.count)
            let count = PacketLengthHelper.encodeLength(len: &length, buf: &array)
            let payloadSize = array[0..<Int(count)]
            
            //build packet: [status:payloadsize:payloadData]
            data?.append(status)
            data?.append(contentsOf: payloadSize)
            data?.append(contentsOf: payloadData)
        }
        if let data = self.data {
            //append crc
            let crc = CRC16CCITT.calc(data: data.array)
            self.data?.append(crc)
        }
        return self
    }
    
}

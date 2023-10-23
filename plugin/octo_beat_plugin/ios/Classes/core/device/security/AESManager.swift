//
//  AESManager.swift
//  eXi
//
//  Created by Hay Tran Van on 10/22/18.
//  Copyright © 2018 Hay Tran Van. All rights reserved.
//

import Foundation
import CryptoSwift

class AESManager: NSObject {
    var deviceName: String
    var key: Array <UInt8>
    var iv: Array <UInt8>
    
    init(deviceName: String) {
        self.deviceName = "Octo-Beat-\(deviceName)"
        let hashedMacAddr = (Data(self.deviceName.bytes).sha256())
        iv = [UInt8] (hashedMacAddr[0..<16])
        key = [UInt8] (hashedMacAddr[16..<32])
        LogUtil.myLogInfo(clazz: "AESMANAGER", methodName: "INT", message: self.deviceName)
        LogUtil.myLogInfo(clazz: "AESMANAGER", methodName: "INT", message: iv.toHexString())
        LogUtil.myLogInfo(clazz: "AESMANAGER", methodName: "INT", message: key.toHexString())
    }
    
    
    func encrypt(data: [UInt8]) -> [UInt8]? {
        do {
            let encrypted = try AES(key: key, blockMode: CTR(iv: iv), padding: .noPadding).encrypt(data)
            return encrypted
        } catch {
            print(error)
            return nil
        }
    }
    
    func decrypt(bytes: [UInt8]) -> [UInt8]? {
        do {
            let decrypted = try AES(key: key, blockMode: CTR(iv: iv), padding: .noPadding).decrypt(bytes)
           return decrypted
        } catch {
            print(error)
            return nil
        }
    }

}

//
//  UnpackParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import MessagePack
class UnpackValue {
    var code: UInt16!
    var values: [MessagePackValue]!
    
    init(code: UInt16, values: [MessagePackValue]) {
        self.code = code
        self.values = values
    }
}

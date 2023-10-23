//
//  Number+ext.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
extension Numeric {
    var data: Data {
        var source = self
        return Data(bytes: &source, count: MemoryLayout<Self>.size)
    }
}

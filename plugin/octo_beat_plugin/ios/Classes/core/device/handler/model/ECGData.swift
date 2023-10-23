//
//  ECGData.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 18/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

struct ECGData {
    var ch1: Float?
    var ch2: Float?
    var ch3: Float?
    
    init() {}
    init(ch1: Float?, ch2: Float?, ch3: Float?) {
        self.ch1 = ch1
        self.ch2 = ch2
        self.ch3 = ch3
    }
}

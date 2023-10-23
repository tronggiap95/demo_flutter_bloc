//
//  ECGSample.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 17/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

struct ECGSample {
    var ch1: [Int16]?
    var ch2: [Int16]?
    var ch3: [Int16]?
    
    init(ch1: [Int16]?,
         ch2: [Int16]?,
         ch3: [Int16]? ) {
        self.ch1 = ch1
        self.ch2 = ch2
        self.ch3 = ch3
    }
}

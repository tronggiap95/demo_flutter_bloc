//
//  REQ_SW_MODE_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class REQ_SW_MODE_PR: CommandParams {
    var mode: String!
    
    init(mode: String){
        self.mode = mode
    }
}

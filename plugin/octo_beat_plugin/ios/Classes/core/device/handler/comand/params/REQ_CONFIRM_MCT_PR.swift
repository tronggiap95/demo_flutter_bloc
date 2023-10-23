//
//  ConfirmMCTParams.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class REQ_CONFIRM_MCT_PR: CommandParams {
    var time: Int!
    var symptoms: [Int]!
    
    init(time: Int, symptoms: [Int]){
        self.time = time
        self.symptoms = symptoms
    }
}

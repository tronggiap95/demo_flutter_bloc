//
//  RSP_TRGGER_MCT_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class RSP_TRIGGER_MCT_PR: CommandParams {
    var responseCode: ResponseCode!
    
    init(responseCode: ResponseCode){
        self.responseCode = responseCode
    }
}

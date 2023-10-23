//
//  NT_NET_CHANGE_PR.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/23/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

class NT_NET_CHANGE_PR: CommandParams {
    var status: Bool!
    
    init(status: Bool){
        self.status = status
    }
}

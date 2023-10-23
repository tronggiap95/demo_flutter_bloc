//
//  RxError.swift
//  Q&C
//
//  Created by Manh Tran on 11/6/19.
//  Copyright © 2019 q-c. All rights reserved.
//

import Foundation


public class RxError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}

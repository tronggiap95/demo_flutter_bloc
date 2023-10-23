//
//  BlueMode.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/26/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation

enum BlueMode {
    case BLE
    case CLASSIC
    
    public var rawValue: String {
        switch self {
        case .BLE:
            return "BLE"
        case .CLASSIC:
            return "Classic"
        }
    }
    
    public static func get(mode: String) -> BlueMode? {
        switch mode {
        case "BLE":
            return .BLE
        case "Classic":
            return .CLASSIC
        default:
            return nil 
        }
    }
}

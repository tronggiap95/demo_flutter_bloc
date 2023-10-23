//
//  IbeaconInterface.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/26/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation
protocol IbeaconInterface {
    func requestPermission()
    func startMonitoring()
}


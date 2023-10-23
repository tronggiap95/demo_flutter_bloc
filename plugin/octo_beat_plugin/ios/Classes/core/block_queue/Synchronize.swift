//
//  Synchronize.swift
//  TestThread
//
//  Created by Manh Tran on 11/2/19.
//  Copyright © 2019 fiot.vn. All rights reserved.
//

import Foundation

func synchronized<T>(_ lock: AnyObject, closure: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    return try closure()
}

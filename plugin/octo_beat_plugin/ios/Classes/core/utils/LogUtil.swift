//
//  LogUtil.swift
//  DXH-ios
//
//  Created by Manh Tran on 11/22/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
public class LogUtil {
    public static let ENABLE_DEBUG_LOG = false
    public static let ENABLE_CLOUD_LOG = false
    static func myLogInfo(clazz: String, methodName: String, message: String){
        if ENABLE_DEBUG_LOG {
            print(message)
//            log.info("CLAZZ[\(clazz)]-METHOD[\(methodName)]-M:\(message)")
        }
    }
    
    static func cloudLog(message: String) {
        if ENABLE_CLOUD_LOG {
//            log.info(message)
        }
    }
}

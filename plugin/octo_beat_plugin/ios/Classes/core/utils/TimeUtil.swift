//
//  TimeUtil.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 9/18/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation
import TrueTime

public class TimeUtil {
    public static let ENABLE_DEBUG_LOG = false
    public static let ENABLE_CLOUD_LOG = false
    
    static func getTimezoneLocalInMinutes()->Int{
        let timezoneLocalInMinutes = TimeZone.current.offsetMinutes()
        return timezoneLocalInMinutes
    }
    
    static func getUTCTrueTime(time: @escaping(Int64)->()) {
        let utcTrueTime = Date().millisecondsSince1970/1000
        time(utcTrueTime)
        
//        // At an opportune time (e.g. app start):
//        let client = TrueTimeClient.sharedInstance
//
//        // To block waiting for fetch, use the following:
//        client.fetchIfNeeded { result in
//            switch result {
//            case .success(_):
//                do {
//                    let utcTrueDate = try result.get().now()
//                    print("utc:", utcTrueDate.timeIntervalSince1970)
//                    utcTrueTime = Int64(utcTrueDate.timeIntervalSince1970)
//                } catch {
//                    print("parse trueTime result error")
//                }
//                time(utcTrueTime)
//            case .failure(_):
//                time(utcTrueTime)
//            }
//        }
    }
}

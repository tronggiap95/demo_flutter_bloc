//
//  Timezone+Extensions.swift
//  Q&C
//
//  Created by Manh Tran on 9/23/19.
//  Copyright © 2019 q-c. All rights reserved.
//

import Foundation

extension TimeZone {
    //return timezone offset: +hhmm
    func offsetFromUTC() -> String
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }
    
    //return timezone offset: +hh:mm
    func offsetInHHmm() -> String
    {
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
    
    //return: Europe/Paris
    func timeZoneName() -> String {
        return TimeZone.current.identifier
    }
    
    //return GMT-2
    func timeZoneAbbreviation() -> String? {
        return TimeZone.current.abbreviation()
    }
    
    func offsetHours() -> Int {
         let hours = secondsFromGMT()/3600
        return hours
    }
    
    func offsetMinutes() -> Int {
        let hours = secondsFromGMT()/3600
        let minutes = (secondsFromGMT()/60) % 60
        return (hours*60 + minutes)
    }
    
    func offsetSeconds() -> Int {
        return secondsFromGMT()
    }
}

//
//  IBeaconManager.swift
//  DXH-ios
//
//  Created by Manh Tran on 5/26/20.
//  Copyright © 2020 software-2. All rights reserved.
//

import Foundation
import CoreLocation

class IBeaconManager: NSObject, IbeaconInterface, CLLocationManagerDelegate {
    private let region = CLBeaconRegion.init(proximityUUID: UUID.init(uuidString: "0000FBFE-0000-1000-8000-00805F9B34FB")!,
                                             identifier: "")
    public static let shared: IbeaconInterface = IBeaconManager()
    private let locationManager = CLLocationManager()
    
    func requestPermission() {
        locationManager.delegate = self
        if(CLLocationManager.authorizationStatus() != .authorizedWhenInUse) {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func startMonitoring() {
        //triggered enter/exit region's range
        locationManager.startMonitoring(for: region)
        //triggered based on proximity to a beacon
//        locationManager.startRangingBeacons(in: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
    }
    
}


/**
 *------------------------------------------------*************--------------------------------**
 *------------------------------------------------*************--------------------------------**
 */
extension IBeaconManager {
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Location manager didStartMonitoringFor: ")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Location manager didStartMonitoringFor:")
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager rangingBeaconsDidFailFor:\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Location manager didEnterRegion:")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Location manager didExitRegion:")
    }
    
}

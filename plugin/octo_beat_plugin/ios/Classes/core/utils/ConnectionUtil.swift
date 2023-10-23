//
//  ConnectionUtil.swift
//  OctoBeat-clinic-ios
//
//  Created by Nha Banh on 01/11/2022.
//  Copyright © 2022 itr.vn. All rights reserved.
//

import Foundation
import Reachability

@objc
protocol ConnectionUtilCallBack {
    func onNetworkChange(hasNetwork: Bool)
}

class ConnectionUtil {
    static let sharedInstance = ConnectionUtil()
    private var reachability : Reachability!
    private var callbacks = [ConnectionUtilCallBack]()
    private var hasConnection = true
    
    func registerConnectionEvent(_ callback: ConnectionUtilCallBack) {
        callbacks.append(callback)
    }
    
    func removeConnectionEvent(_ callback: ConnectionUtilCallBack) {
        callbacks.removeAll {$0 === callback}
    }
    
    func observeReachability(){
        do {
            try self.reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            if !hasConnection {
                self.callbacks.forEach{
                    $0.onNetworkChange(hasNetwork: true)
                }
            }
            
            hasConnection = true
            break
        case .wifi:
            print("Network available via WiFi.")
            if !hasConnection {
                self.callbacks.forEach{
                    $0.onNetworkChange(hasNetwork: true)
                }
            }

            hasConnection = true
            break
        case .none:
            print("Network is not available.")
            self.callbacks.forEach{
                $0.onNetworkChange(hasNetwork: false)
            }
            
            hasConnection = false
            break
        case .unavailable:
            print("Network is  unavailable.")
            self.callbacks.forEach{
                $0.onNetworkChange(hasNetwork: false)
            }
            
            hasConnection = false
            break
        }
    }
}

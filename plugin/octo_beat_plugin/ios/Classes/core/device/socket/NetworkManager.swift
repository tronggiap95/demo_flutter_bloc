//
//  NetworkManager.swift
//  DXH-ios
//
//  Created by Manh Tran on 12/4/19.
//  Copyright © 2019 software-2. All rights reserved.
//

import Foundation
import Reachability

protocol NetDelegate: class {
    func netStatus(on: Bool)
}

class NetworkManager {
    private let TAG = "NETWORK_MANAGER"
    public static let sharedInstance = NetworkManager()
    private var reachability: Reachability!
    private var netDelegates = [NetDelegate]()
    
    private init () {
        self.registerNetChangingState()
    }
    
    func registerNetDelegate(_ delegate: NetDelegate) {
        netDelegates.append(delegate)
    }
    
    func removeNetDelegate(_ delegate: NetDelegate) {
        netDelegates.removeAll {$0 === delegate}
    }
    
    private func notifyNetChange(status: Bool) {
        self.netDelegates.forEach{
            $0.netStatus(on: status)
        }
    }
    
    
    private func registerNetChangingState() {
        do {
            reachability = try Reachability(hostname: "www.google.com")
            reachability.whenReachable = { reachability in
                self.notifyNetChangeHandler()
                self.notifyNetChange(status: true)
                if reachability.connection == .wifi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
            }
            reachability.whenUnreachable = { _ in
                self.notifyNetChangeHandler()
                self.notifyNetChange(status: false)
                print("Not reachable")
            }
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func notifyNetChangeHandler() {
        let devices = CoreManager.sharedInstance.getDevices()
        devices.forEach{ device in
            if let id = device.deviceId {
                CoreManager.sharedInstance.NotifyUI(updateType: .SERVER_TCP_CONNECTION, deviceId: id)
                if let blueHandler =  DeviceManager.sharedInstance.getBlueHandler(deviceId: id) {
                    CommandFactory.sendPacket(type: CommandType.NT_NET_CHANGE,
                                              params: NT_NET_CHANGE_PR(status: isNetAvailable()),
                                              blueHandler: blueHandler)
                }
                LogUtil.myLogInfo(clazz: TAG, methodName: "NT_NET_CHANGE", message: "DATA: \(isNetAvailable())")
            }
        }
    }
    
    func isNetAvailable() -> Bool {
        return reachability.connection == .wifi || reachability.connection == .cellular
    }
    
}

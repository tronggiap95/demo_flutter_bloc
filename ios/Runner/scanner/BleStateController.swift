//
//  BleStateController.swift
//  Runner
//
//  Created by Manh Tran on 25/09/2023.
//

import Foundation
import CoreBluetooth

protocol BleStateListener: NSObjectProtocol {
    func onBluetoothOn()
    func onBluetoothOff()
}

@objcMembers class BleStateController: NSObject, CBCentralManagerDelegate {
    static let shared = BleStateController()
    private var mCentralManger: CBCentralManager? = nil
    private var isBluetoothOn = false
    
    private var mListener: BleStateListener? = nil;
    
    
    func initialization(){
        mCentralManger = CBCentralManager(delegate: self, queue: nil)
    }
    
    func setListener(listener: BleStateListener) {
        mListener = listener
    }
    
    func isBluetoothEnable() -> Bool {
        return isBluetoothOn
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isBluetoothOn = central.state == CBManagerState.poweredOn
        if (isBluetoothOn) {
            mListener?.onBluetoothOn()
        } else {
            mListener?.onBluetoothOff()
        }
    }
    
    func isBluetoothAuthorized() -> Bool {
        
        if #available(iOS 13.1, *) { return CBCentralManager.authorization == .allowedAlways }
        
        if #available(iOS 13.0, *) { return CBCentralManager().authorization == .allowedAlways }
        
        return true
        
    }
}



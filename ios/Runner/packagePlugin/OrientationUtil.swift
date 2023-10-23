//
//  OrientationUtil.swift
//  Runner
//
//  Created by Ta Cuong on 31/05/2023.
//

import Foundation
import UIKit

struct OrientationUtil {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
        if #available(iOS 16.0, *) {
                           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: UIInterfaceOrientationMask(rawValue: orientation.rawValue) ))
        } else {
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        }
        UINavigationController.attemptRotationToDeviceOrientation()
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        self.lockOrientation(orientation)
        if #available(iOS 16.0, *) {
                           let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: rotateOrientation.isLandscape ? UIInterfaceOrientationMask.landscape : UIInterfaceOrientationMask.portrait))
        } else {
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
        
        UINavigationController.attemptRotationToDeviceOrientation()
    }

}

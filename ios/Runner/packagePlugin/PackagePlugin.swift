//
//  PackagePlugin.swift
//  Runner
//
//  Created by Manh Tran on 09/11/2022.
//

//
//  NotificationPlugin.swift
//  Runner
//
//  Created by Manh Tran on 07/11/2022.
//

//
//  Spo2Plugin.swift
//  Runner
//
//  Created by Manh Tran on 12/10/2022.
//

import Foundation

class PackagePlugin  {
    enum Method: String {
        case GET_APP_VERSION = "getAppVersion"
        case SET_SCREEN_ORIENTATION = "setScreenOrientation"
        case OPEN_GENERAL_SETTING = "openGeneralSetting"
        case SIGN_OUT = "signOut"
    }
    
    static func register(with messenger: FlutterBinaryMessenger)  {
        let instance = PackagePlugin()
        let channel = FlutterMethodChannel(name: "com.octomed.octo360.package_manager.method_channel", binaryMessenger: messenger)
        channel.setMethodCallHandler(instance.handle)
    }
        
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("method call \(call.method)")
        switch call.method {
        case Method.GET_APP_VERSION.rawValue:
            let dictionary = Bundle.main.infoDictionary!
            let version = dictionary["CFBundleShortVersionString"] as? String
            result(version ?? "")
            break
        case Method.SET_SCREEN_ORIENTATION.rawValue:
            let params = call.arguments as? Array<Any>
            let orientation = params?[0] as? Int
            switch (orientation) {
            case 0:
                OrientationUtil.lockOrientation(UIInterfaceOrientationMask.portrait)
                break
            case 1:
                OrientationUtil.lockOrientation(UIInterfaceOrientationMask.portraitUpsideDown)
                break
            case 2:
                OrientationUtil.lockOrientation(UIInterfaceOrientationMask.all)
                break
            case 3:
                OrientationUtil.lockOrientation(UIInterfaceOrientationMask.all)
                break
            default:
                break
            }
            break
        case Method.OPEN_GENERAL_SETTING.rawValue:
            openPhoneSettings(completion: {
                isSuccess in
                result(isSuccess)
            })
            break
        default:
            result(nil)
        }
    }
    
     func openPhoneSettings(completion: @escaping (_ isSuccess: Bool) -> ()) {
          guard let url = URL(string: "App-Prefs:root=General") else {
              completion(false)
              return
          }

          let app = UIApplication.shared

          app.open(url) { isSuccess in
              completion(isSuccess)
          }
      }
    
}

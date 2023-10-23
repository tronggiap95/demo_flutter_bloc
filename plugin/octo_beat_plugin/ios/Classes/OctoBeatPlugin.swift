import Flutter
import UIKit

public class OctoBeatPlugin: NSObject, FlutterPlugin {
    enum Method: String {
        case GET_DEVICE_INFO = "getDeviceInfo"
        case SUBMIT_MCT_EVENT = "submitMctEvent"
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "octo_beat_plugin", binaryMessenger: registrar.messenger())
        let instance = OctoBeatPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        OctoBeatConnectionPlugin.register(with: registrar.messenger())
        OctoBeatEventPlugin.register(with: registrar.messenger())
        
        reconnectWhenOpenApp()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let params = call.arguments as? Array<Any>
        print("OctoBeatCorePlugin call.method \(call.method)")
        switch call.method {
        case Method.GET_DEVICE_INFO.rawValue:
            OctoBeatPluginHelper.shared.getDeviceInfo(result: result)
            break
        case Method.SUBMIT_MCT_EVENT.rawValue:
            OctoBeatPluginHelper.shared.submitMctEvent(params: params, result: result)
            break
        default:
            result(nil)
        }
    }
    
    private static func reconnectWhenOpenApp() {
        let dd =  CoreManager.sharedInstance.initDevice()
        if (dd?.deviceId) != nil {
            CoreManager.sharedInstance.reconnectWhenOpen()
        }
    }
}

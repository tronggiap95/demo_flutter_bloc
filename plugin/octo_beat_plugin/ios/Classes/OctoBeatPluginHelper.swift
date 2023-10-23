//  OctoBeatPluginHelper.swift

import Foundation
import Flutter

class OctoBeatPluginHelper: NSObject {
    static let shared: OctoBeatPluginHelper = OctoBeatPluginHelper()
    
    func getDeviceInfo(result: @escaping FlutterResult) {
        let devices = CoreManager.sharedInstance.getDevices()
        guard let dd: DeviceDisplay = devices.first else {
            getLocalDevice(result: result)
            return
        }
        let deviceMap = ObjectParser.parseDeviceInfo(device: dd)
        result(deviceMap)
    }
    
    private func getLocalDevice(result: @escaping FlutterResult) {
        let deviceDisplay = CoreManager.sharedInstance.initDevice()
        guard let dd: DeviceDisplay = deviceDisplay else {
            result(nil)
            return
        }
        result(dd)
    }
    
    func submitMctEvent(params: Array<Any>?, result: @escaping FlutterResult){
        let devices = CoreManager.sharedInstance.getDevices()
        if (devices.isEmpty) {
            result(false)
            return
        }
        guard let deviceId = devices[0].deviceId, let evTime = params?[0] as? Int, let symptoms = params?[1] as? [Int] else {
            result(false)
            return
        }
        let blueHandler = DeviceManager.sharedInstance.getBlueHandler(deviceId: deviceId)
        CommandFactory.sendPacket(type: CommandType.REQ_CONFIRM_MCT, params: REQ_CONFIRM_MCT_PR(time: evTime, symptoms: symptoms), blueHandler: blueHandler)
        result(true)
    }
}

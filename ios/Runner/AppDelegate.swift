import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
var orientationLock = UIInterfaceOrientationMask.portrait

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      
    PackagePlugin.register(with: controller.binaryMessenger)
    ScannerPlugin.register(with: controller.binaryMessenger)
    GeneratedPluginRegistrant.register(with: self)
      
    application.applicationIconBadgeNumber = 0
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
               return self.orientationLock
    }
}

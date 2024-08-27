import Flutter
import UIKit
import VeriphOne
import SwiftUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let veriphOneChannel = FlutterMethodChannel(name: "one.veriph.sdk/verification",
                                                    binaryMessenger: controller.binaryMessenger)
        
        veriphOneChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "startVerification" {
                guard let args = call.arguments as? [String: String],
                      let apiKey = args["apiKey"],
                      let sessionUuid = args["sessionUuid"] else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument(s) provided", details: nil))
                    return
                }
                self.startVerification(apiKey: apiKey, sessionUuid: sessionUuid, controller: controller, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func startVerification(apiKey: String, sessionUuid: String, controller: FlutterViewController, result: @escaping FlutterResult) {
        let veriphOneView = VeriphOneView(sessionUuid: sessionUuid, apiKey: apiKey) { a in
            if let a = a {
                result(a)
                DispatchQueue.main.async {
                    controller.dismiss(animated: true)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument(s) provided", details: nil))
            }
        }
        
        let hostingController = UIHostingController(rootView: veriphOneView)
        controller.present(hostingController, animated: true)
    }
}

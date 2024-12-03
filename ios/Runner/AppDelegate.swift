

import UIKit
import Flutter
import LocalAuthentication

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "com.example.flutter_platform_channels/battery", binaryMessenger: controller.binaryMessenger)

        batteryChannel.setMethodCallHandler { (call, result) in
            if call.method == "getBatteryLevel" {
                self.getBatteryLevel(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        let biometricChannel = FlutterMethodChannel(name: "com.example/biometric", binaryMessenger: controller.binaryMessenger)

        biometricChannel.setMethodCallHandler { (call, result) in
            if call.method == "authenticate" {
                self.authenticateUser(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func authenticateUser(result: @escaping FlutterResult) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the battery level screen"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluationError in
                DispatchQueue.main.async {
                    if success {
                        result(true)
                    } else {
                        result(false)
                    }
                }
            }
        } else {
            result(FlutterError(
                code: "UNAVAILABLE",
                message: "Biometric authentication not available.",
                details: nil
            ))
        }
    }

    private func getBatteryLevel(result: @escaping FlutterResult) {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        if device.batteryState != .unknown {
            let batteryLevel = Int(device.batteryLevel * 100)
            result(batteryLevel)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Battery info unavailable", details: nil))
        }
    }
}

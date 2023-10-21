import UIKit
import Flutter
import CallKit
import AVKit

//class AirPlayDetector {
//    static func isAirPlayActive() -> Bool {
//        let screen = UIScreen.main
//        return screen.isAirPlayScreen
//    }
//}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var callObserver: CXCallObserver?
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let airPlayChannel = FlutterMethodChannel(name: "com.brainchief/isAirPlayActive",
                                                      binaryMessenger: controller.binaryMessenger)
         
        airPlayChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
          // This method is invoked on the UI thread.
          guard call.method == "getAirplayStatus" else {
            result(FlutterMethodNotImplemented)
            return
          }
          self?.getAirplayStatus(result: result)
        })
        self.window.makeSecure()
        
        if isCallKitSupported() {
            callObserver = CXCallObserver()
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
   var isAudioSessionUsingAirplayOutputRoute: Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute

        for outputPort in currentRoute.outputs {
            if outputPort.portType == AVAudioSession.Port.airPlay {
                return true
            }
        }

        return false
    }

    private func getAirplayStatus(result: FlutterResult) {
        let isAudioActive = isAudioSessionUsingAirplayOutputRoute
        let isAirPlayActive = UIScreen.screens.count > 1
        result(isAirPlayActive || isAudioActive)
    }
    
    override func applicationWillResignActive(
        _ application: UIApplication
    ) {
        self.window.isHidden = true;
    }
    override func applicationDidBecomeActive(
        _ application: UIApplication
    ) {
        self.window.isHidden = false;
    }
    func isCallKitSupported() -> Bool {
        let userLocale = NSLocale.current
        
        guard let regionCode = userLocale.regionCode else { return false }
        
        if regionCode.contains("CN") ||
            regionCode.contains("CHN") {
            return false
        } else {
            return true
        }
    }
    
}

// extension UIWindow {
// func makeSecure() {
//     let field = UITextField()
//     field.isSecureTextEntry = true
//     self.addSubview(field)
//     field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//     field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//     self.layer.superlayer?.addSublayer(field.layer)
//     field.layer.sublayers?.first?.addSublayer(self.layer)
//   }
// }
extension UIWindow {
    func makeSecure() {
        let field = UITextField()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: field.frame.self.width, height: field.frame.self.height))
        field.isSecureTextEntry = true
        self.addSubview(field)
        self.layer.superlayer?.addSublayer(field.layer)
        field.layer.sublayers?.last!.addSublayer(self.layer)
        field.leftView = view
        field.leftViewMode = .always
    }
}

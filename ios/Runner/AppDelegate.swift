import UIKit
import Flutter
import CallKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var callObserver: CXCallObserver?
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        self.window.makeSecure()
        
        if isCallKitSupported() {
            callObserver = CXCallObserver()
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
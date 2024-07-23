import UIKit
import Flutter
import GoogleMaps  // Import the Google Maps module

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Google Maps services with your API key
    GMSServices.provideAPIKey("AIzaSyC8KhMfL0uOnxmyfagABb9tm-CRphTEydI")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
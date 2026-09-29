import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Self.googleMapsApiKey(), !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    } else {
      NSLog("[AppDelegate] ⚠️ GOOGLE_MAPS_API_KEY not found in .env — maps will crash.")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// Reads GOOGLE_MAPS_API_KEY from the `.env` file bundled via flutter_dotenv
  /// so the native Maps SDK and the Dart side share a single source of truth.
  private static func googleMapsApiKey() -> String? {
    guard let contents = loadDotEnvContents() else { return nil }

    for rawLine in contents.split(whereSeparator: { $0 == "\n" || $0 == "\r" }) {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      guard !line.isEmpty, !line.hasPrefix("#"),
        let separatorIndex = line.firstIndex(of: "=")
      else { continue }

      let key = line[..<separatorIndex].trimmingCharacters(in: .whitespaces)
      if key == "GOOGLE_MAPS_API_KEY" {
        return line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespaces)
      }
    }
    return nil
  }

  /// The `.env` asset can live in a few places depending on the Flutter
  /// version / build (main bundle vs. embedded App.framework), so try them all.
  private static func loadDotEnvContents() -> String? {
    var candidatePaths: [String] = []

    // 1) Flutter's own asset key lookup (most correct).
    let assetKey = FlutterDartProject.lookupKey(forAsset: ".env")
    if let path = Bundle.main.path(forResource: assetKey, ofType: nil) {
      candidatePaths.append(path)
    }

    // 2) Directly under the main bundle's flutter_assets.
    if let path = Bundle.main.path(
      forResource: ".env", ofType: nil, inDirectory: "flutter_assets")
    {
      candidatePaths.append(path)
    }

    // 3) Inside the embedded App.framework (modern Flutter iOS builds).
    if let frameworksURL = Bundle.main.privateFrameworksURL {
      let frameworkEnv = frameworksURL
        .appendingPathComponent("App.framework")
        .appendingPathComponent("flutter_assets")
        .appendingPathComponent(".env")
      candidatePaths.append(frameworkEnv.path)
    }

    for path in candidatePaths {
      if let contents = try? String(contentsOfFile: path, encoding: .utf8) {
        return contents
      }
    }
    return nil
  }
}

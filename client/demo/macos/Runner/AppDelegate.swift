import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // 必须持有引用，否则被 ARC 回收
  var windowChannel: FlutterMethodChannel?

  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    guard let window = NSApplication.shared.windows.first,
          let controller = window.contentViewController as? FlutterViewController else { return }

    windowChannel = FlutterMethodChannel(
      name: "santuan/window",
      binaryMessenger: controller.engine.binaryMessenger
    )

    windowChannel?.setMethodCallHandler { (call, result) in
      switch call.method {
      case "startDrag":
        if let event = NSApplication.shared.currentEvent {
          window.performDrag(with: event)
        }
        result(nil)
      case "close":
        NSApplication.shared.terminate(nil)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // ── 透明无边框窗口 ──
    self.isOpaque = false
    self.backgroundColor = NSColor.clear
    self.hasShadow = false
    self.styleMask = [.borderless]
    self.level = .floating
    flutterViewController.backgroundColor = .clear

    // 设置初始窗口尺寸
    let petSize = NSSize(width: 300, height: 360)
    self.setContentSize(petSize)

    // 定位到屏幕右下角
    if let screen = NSScreen.main {
      let screenRect = screen.visibleFrame
      let x = screenRect.maxX - petSize.width - 40
      let y = screenRect.minY + 40
      self.setFrameOrigin(NSPoint(x: x, y: y))
    }

    super.awakeFromNib()
  }

  override var canBecomeKey: Bool { true }
  override var canBecomeMain: Bool { true }
}

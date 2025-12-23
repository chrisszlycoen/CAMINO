import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.setFrame(windowFrame, display: true)
    self.contentViewController = flutterViewController


    RegisterGeneratedPlugins(registry: flutterViewController) 

    super.awakeFromNib()
  }
}

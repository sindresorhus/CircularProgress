import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	@IBOutlet var circularProgress: CircularProgress!

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.isMovableByWindowBackground = true
		window.makeVibrant()
		window.center()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		circularProgress.showCheckmarkAtHundredPercent = true

		animateWithRandomColor()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	func animateWithRandomColor() {
		var startAnimating: (() -> Void)!
		var timer: Timer!

		startAnimating = {
			self.circularProgress.resetProgress()
			self.circularProgress.color = NSColor.uniqueRandomSystemColor()

			timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
				self.circularProgress.progress += 0.01

				if self.circularProgress.progress == 1 {
					timer.invalidate()

					delay(seconds: 1) {
						startAnimating()
					}
				}
			}
		}

		startAnimating()
	}
}

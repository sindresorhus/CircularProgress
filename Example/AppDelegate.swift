import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	let circularProgress = CircularProgress(size: 200)

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.isMovableByWindowBackground = true
		window.makeVibrant()
		window.center()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		let view = window.contentView!

		circularProgress.frame = circularProgress.frame.centered(in: view.bounds)
		circularProgress.showCheckmarkAtHundredPercent = true
		view.addSubview(circularProgress)

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

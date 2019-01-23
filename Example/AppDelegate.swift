import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	@IBOutlet private var circularProgress: CircularProgress!

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

	private func animateWithRandomColor() {
		var startAnimating: (() -> Void)!
		var timer: Timer!

		startAnimating = {
			let progress = Progress(totalUnitCount: 50)
			self.circularProgress.progressInstance = progress

			self.circularProgress.resetProgress()
			self.circularProgress.color = NSColor.uniqueRandomSystemColor()

			timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
				progress.completedUnitCount += 1

				if progress.isFinished || progress.isCancelled {
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

import Cocoa
/**
Makes it possible to utilize mouseOver/mouseOut functionality on a view (Supports custom bezier path)
*/
protocol MouseTrackable: class {
	var hitTestPath: CGPath? { get }
}
extension MouseTrackable where Self: NSView {
	/**
	* Creates a new tracking area (removes old)
	*/
	func createTrackingArea(_ options: NSTrackingArea.Options = [.activeInActiveApp, .mouseEnteredAndExited, .mouseMoved]) {
		trackingAreas.forEach { trackingArea in
			self.removeTrackingArea(trackingArea)
		}
		let trackingArea: NSTrackingArea = .init(rect: self.bounds, options: options, owner: self, userInfo: nil)
		self.addTrackingArea(trackingArea)
	}
	/**
	Stores/generates the path to hitTest against
	*/
	var hitTestPath: CGPath? { return nil }
}

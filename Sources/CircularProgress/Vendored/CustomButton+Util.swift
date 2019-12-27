import Cocoa

/**
Convenience class for adding a tracking area to a view.

```
final class HoverView: NSView {
	private lazy var trackingArea = TrackingArea(
		for: self,
		options: [
			.mouseEnteredAndExited,
			.activeInActiveApp
		]
	)

	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		trackingArea.update()
	}
}
```
*/
final class TrackingArea {
	private weak var view: NSView?
	private let rect: CGRect
	private let options: NSTrackingArea.Options
	private var trackingArea: NSTrackingArea?

	/**
	- Parameters:
		- view: The view to add tracking to.
		- rect: The area inside the view to track. Defaults to the whole view (`view.bounds`).
	*/
	init(
		for view: NSView,
		rect: CGRect? = nil,
		options: NSTrackingArea.Options = []
	) {
		self.view = view
		self.rect = rect ?? view.bounds
		self.options = options
	}

	/**
	Updates the tracking area.
	- Note: This should be called in your `NSView#updateTrackingAreas()` method.
	*/
	func update() {
		if let oldTrackingArea = trackingArea {
			view?.removeTrackingArea(oldTrackingArea)
		}

		let newTrackingArea = NSTrackingArea(
			rect: rect,
			options: [
				.mouseEnteredAndExited,
				.activeInActiveApp
			],
			owner: view,
			userInfo: nil
		)

		view?.addTrackingArea(newTrackingArea)
		trackingArea = newTrackingArea
	}
}


final class AnimationDelegate: NSObject, CAAnimationDelegate {
	var didStopHandler: ((Bool) -> Void)?

	func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
		didStopHandler?(flag)
	}
}


protocol LayerColorAnimation: AnyObject {}
extension LayerColorAnimation where Self: CALayer {
	func animate(color: CGColor, keyPath: ReferenceWritableKeyPath<Self, CGColor?>, duration: Double) {
		let keyPathStr = NSExpression(forKeyPath: keyPath).keyPath
		let animation = CABasicAnimation(keyPath: keyPathStr)
		animation.fromValue = self[keyPath: keyPath]
		animation.toValue = color
		animation.duration = duration
		animation.fillMode = .forwards
		animation.isRemovedOnCompletion = false
		add(animation, forKey: keyPathStr) { [weak self] _ in
			self?[keyPath: keyPath] = color
		}
	}
}


extension CALayer: LayerColorAnimation {
	func add(_ animation: CAAnimation, forKey key: String?, completion: @escaping ((Bool) -> Void)) {
		let animationDelegate = AnimationDelegate()
		animationDelegate.didStopHandler = completion
		animation.delegate = animationDelegate
		add(animation, forKey: key)
	}
}


extension CGPoint {
	func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
		Self(x: x.rounded(rule), y: y.rounded(rule))
	}
}


extension CGRect {
	func roundedOrigin(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
		var rect = self
		rect.origin = rect.origin.rounded(rule)
		return rect
	}
}


extension CGSize {
	/// Returns a CGRect with `self` centered in it.
	func centered(in rect: CGRect) -> CGRect {
		CGRect(
			x: (rect.width - width) / 2,
			y: (rect.height - height) / 2,
			width: width,
			height: height
		)
	}
}

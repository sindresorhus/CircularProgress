import Cocoa

@IBDesignable
public final class CircularProgress: NSView {
	private var lineWidth: Double = 2
	private lazy var radius = bounds.width < bounds.height ? bounds.midX * 0.8 : bounds.midY * 0.8
	private var _progress: Double = 0
	private var progressObserver: NSKeyValueObservation?
	private var finishedObserver: NSKeyValueObservation?
	private var cancelledObserver: NSKeyValueObservation?

	private lazy var backgroundCircle = with(CAShapeLayer.circle(radius: Double(radius), center: bounds.center)) {
		$0.frame = bounds
		$0.fillColor = nil
		$0.lineWidth = CGFloat(lineWidth) / 2
		$0.strokeColor = color.with(alpha: 0.5).cgColor
	}

	private lazy var progressCircle = with(ProgressCircleShapeLayer(radius: Double(radius), center: bounds.center)) {
		$0.lineWidth = CGFloat(lineWidth)
	}

	private lazy var progressLabel = with(CATextLayer(text: "0%")) {
		$0.color = color
		$0.fontSize = bounds.width < bounds.height ? bounds.width * 0.2 : bounds.height * 0.2
		$0.frame = CGRect(x: 0, y: 0, width: bounds.width, height: $0.preferredFrameSize().height)
		$0.position = CGPoint(x: bounds.midX, y: bounds.midY)
		$0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		$0.alignmentMode = .center
		$0.font = NSFont.helveticaNeueLight // Not using the system font as it has too much number width variance
	}

	private lazy var cancelButton = with(CustomButton.circularButton(title: "╳", radius: Double(radius), center: bounds.center)) {
		$0.textColor = color
		$0.backgroundColor = color.with(alpha: 0.1)
		$0.activeBackgroundColor = color
		$0.borderWidth = 0
		$0.isHidden = true
		$0.onAction = { _ in
			self.cancelProgress()
		}
	}

	/**
	Color of the circular progress view.

	Defaults to the user's accent color. For High Sierra and below it uses a fallback color.
	*/
	@IBInspectable public var color: NSColor = .controlAccentColorPolyfill {
		didSet {
			needsDisplay = true
		}
	}

	/**
	Show `✔` instead `100%`.
	*/
	@IBInspectable public var showCheckmarkAtHundredPercent: Bool = true

	/**
	The progress value in the range `0...1`.

	- Note: The value will be clamped to `0...1`.
	*/
	@IBInspectable public var progress: Double {
		get {
			return _progress
		}
		set {
			_progress = newValue.clamped(to: 0...1)

			// swiftlint:disable:next trailing_closure
			CALayer.animate(duration: 0.5, timingFunction: .easeOut, animations: {
				self.progressCircle.progress = self._progress
			})

			if !progressLabel.isHidden {
				progressLabel.string = "\(Int(_progress * 100))%"
			}

			if _progress == 1 {
				isFinished = true
			}

			// TODO: Figure out why I need to flush here to get the label to update in `Gifski.app`.
			CATransaction.flush()
		}
	}

	private var _isFinished = false
	/**
	Returns whether the progress is finished.
	*/
	@IBInspectable public private(set) var isFinished: Bool {
		get {
			if let progressInstance = progressInstance {
				return progressInstance.isFinished
			}

			return _isFinished
		}
		set {
			_isFinished = newValue

			if _isFinished && showCheckmarkAtHundredPercent {
				progressLabel.string = "✓"
			}
		}
	}

	/**
	Let a `Progress` instance update the `progress` for you.
	*/
	public var progressInstance: Progress? {
		didSet {
			if let progressInstance = progressInstance {
				progressObserver = progressInstance.observe(\.fractionCompleted) { sender, _ in
					guard !self.isCancelled && !sender.isFinished else {
						return
					}

					self.progress = sender.fractionCompleted
				}

				finishedObserver = progressInstance.observe(\.isFinished) { sender, _ in
					guard !self.isCancelled && sender.isFinished else {
						return
					}

					self.progress = 1
				}

				cancelledObserver = progressInstance.observe(\.isCancelled) { sender, _ in
					self.isCancelled = sender.isCancelled
				}

				isCancellable = progressInstance.isCancellable
			}
		}
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	override public func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		commonInit()
		progressCircle.progress = _progress
	}

	/**
	Initialize the progress view with a width/height of the given `size`.
	*/
	public convenience init(size: Double) {
		self.init(frame: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
	}

	override public func updateLayer() {
		updateColors()
	}

	private func updateColors() {
		let duration = 0.2

		backgroundCircle.animate(color: color.with(alpha: 0.5).cgColor, keyPath: #keyPath(CAShapeLayer.strokeColor), duration: duration)
		progressCircle.animate(color: color.cgColor, keyPath: #keyPath(CAShapeLayer.strokeColor), duration: duration)

		progressLabel.animate(color: color.cgColor, keyPath: #keyPath(CATextLayer.foregroundColor), duration: duration)

		cancelButton.textColor = color
		cancelButton.backgroundColor = color.with(alpha: 0.1)
		cancelButton.activeBackgroundColor = color
	}

	private func commonInit() {
		wantsLayer = true
		layer?.addSublayer(backgroundCircle)
		layer?.addSublayer(progressCircle)
		layer?.addSublayer(progressLabel)

		addSubview(cancelButton)
	}

	/**
	Reset the progress back to zero without animating.
	*/
	public func resetProgress() {
		_progress = 0
		_isFinished = false
		_isCancelled = false
		progressCircle.resetProgress()
		progressLabel.string = "0%"
	}

	/**
	Cancels `Progress` if it's set and prevents further updates.
	*/
	public func cancelProgress() {
		guard isCancellable else {
			return
		}

		guard let progressInstance = progressInstance else {
			isCancelled = true
			return
		}

		progressInstance.cancel()
	}

	/**
	Triggers when the progress was cancelled succesfully.
	*/
	public var onCancelled: (() -> Void)?

	public var _isCancellable = false
	/**
	If the progress view is cancellable it shows the cancel button.
	*/
	@IBInspectable public var isCancellable: Bool {
		get {
			if let progressInstance = progressInstance {
				return progressInstance.isCancellable
			}

			return _isCancellable
		}
		set {
			_isCancellable = newValue
			updateTrackingAreas()
		}
	}

	private var _isCancelled = false
	/**
	Returns whether the progress has been cancelled.
	*/
	@IBInspectable public private(set) var isCancelled: Bool {
		get {
			if let progressInstance = progressInstance {
				return progressInstance.isCancelled
			}

			return _isCancelled
		}
		set {
			_isCancelled = newValue

			if newValue {
				onCancelled?()
				visualizeCancelledState()
			}
		}
	}

	/**
	Indicates how to visualize the cancelled state.
	*/
	public enum CancelledStateVisualizationMethod {
		case none, desaturate, disable
	}

	/**
	Supply the base color to use for displaying the cancelled state.
	*/
	public var cancelledStateColorHandler: ((NSColor) -> NSColor)?

	/**
	Returns whether to visually show that the progress view is cancelled.
	*/
	public var cancelledStateVisualizationMethod: CancelledStateVisualizationMethod = .desaturate

	private func visualizeCancelledState() {
		if let colorHandler = cancelledStateColorHandler {
			color = colorHandler(color)

			updateColors()
		}

		switch cancelledStateVisualizationMethod {
		case .desaturate:
			color = color.desaturating(by: 0.7)
		case .disable:
			color = .disabledControlTextColor
		default:
			return
		}

		updateColors()
	}

	private var trackingArea: NSTrackingArea?

	override public func updateTrackingAreas() {
		if let oldTrackingArea = trackingArea {
			removeTrackingArea(oldTrackingArea)
		}

		guard isCancellable else {
			return
		}

		let newTrackingArea = NSTrackingArea(
			rect: cancelButton.frame,
			options: [
				.mouseEnteredAndExited,
				.activeInActiveApp
			],
			owner: self,
			userInfo: nil
		)

		addTrackingArea(newTrackingArea)
		trackingArea = newTrackingArea
	}

	override public func mouseEntered(with event: NSEvent) {
		guard isCancellable else {
			super.mouseEntered(with: event)
			return
		}

		progressLabel.isHidden = true
		cancelButton.fadeIn()
	}

	override public func mouseExited(with event: NSEvent) {
		guard isCancellable else {
			super.mouseExited(with: event)
			return
		}

		progressLabel.isHidden = false
		cancelButton.isHidden = true
	}
}

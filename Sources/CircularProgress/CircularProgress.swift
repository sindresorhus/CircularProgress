import Cocoa

@MainActor
@IBDesignable
public final class CircularProgress: NSView {
	private lazy var radius = bounds.width < bounds.height ? bounds.midX * 0.8 : bounds.midY * 0.8
	private var _progress: Double = 0
	private var progressObserver: NSKeyValueObservation?
	private var finishedObserver: NSKeyValueObservation?
	private var cancelledObserver: NSKeyValueObservation?
	private var indeterminateObserver: NSKeyValueObservation?

	private lazy var backgroundCircle = with(CAShapeLayer.circle(radius: radius, center: bounds.center)) {
		$0.frame = bounds
		$0.fillColor = nil
		$0.lineWidth = lineWidth / 2
	}

	private lazy var progressCircle = with(ProgressCircleShapeLayer(radius: radius, center: bounds.center)) {
		$0.lineWidth = lineWidth
	}

	private lazy var progressLabel = with(CATextLayer(text: "0%")) {
		$0.color = color
		$0.fontSize = bounds.width < bounds.height ? bounds.width * 0.2 : bounds.height * 0.2
		$0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		$0.alignmentMode = .center
		$0.font = NSFont.helveticaNeueLight // Not using the system font as it has too much number width variance
		$0.frame = CGRect(x: 0, y: 0, width: bounds.width, height: $0.preferredFrameSize().height)
		$0.position = CGPoint(x: bounds.midX, y: bounds.midY)
		$0.isHidden = true
	}

	lazy var indeterminateCircle = with(IndeterminateProgressCircleShapeLayer(radius: radius, center: bounds.center)) {
		$0.lineWidth = lineWidth
	}

	private lazy var cancelButton = with(CustomButton.circularButton(title: "╳", radius: radius, center: bounds.center)) {
		$0.textColor = color
		$0.backgroundColor = color.withAlphaComponent(0.1)
		$0.activeBackgroundColor = color
		$0.borderWidth = 0
		$0.isHidden = true
		$0.onAction = { [weak self] _ in
			self?.cancelProgress()
		}
	}

	private lazy var successView = with(CheckmarkView(frame: bounds)) {
		$0.color = color
		$0.lineWidth = lineWidth
		$0.isHidden = true
	}

	private var originalColor = NSColor.controlAccentColor
	private var _color = NSColor.controlAccentColor

	/**
	Color of the circular progress view.
	*/
	@IBInspectable public var color: NSColor {
		get { _color }
		set {
			_color = newValue
			originalColor = newValue
			needsDisplay = true
		}
	}

	/**
	Line width of the circular progress view.
	*/
	@IBInspectable public var lineWidth: Double = 2 {
		didSet {
			backgroundCircle.lineWidth = lineWidth / 2
			progressCircle.lineWidth = lineWidth
			indeterminateCircle.lineWidth = lineWidth
			successView.lineWidth = lineWidth
		}
	}

	/**
	Show an animated checkmark instead of `100%`.
	*/
	@IBInspectable public var showCheckmarkAtHundredPercent: Bool = true

	/**
	The progress value in the range `0...1`.

	- Note: The value will be clamped to `0...1`.
	*/
	@IBInspectable public var progress: Double {
		get { _progress }
		set {
			_progress = newValue.clamped(to: 0...1)

			// swiftlint:disable:next trailing_closure
			CALayer.animate(duration: 0.5, timingFunction: .easeOut, animations: { [weak self] in
				guard let self else {
					return
				}

				progressCircle.progress = _progress
			})

			progressLabel.isHidden = isLabelHidden || (progress == 0 && isIndeterminate ? cancelButton.isHidden : !cancelButton.isHidden)

			if !progressLabel.isHidden {
				progressLabel.string = "\(Int(_progress * 100))%"
				successView.isHidden = true
			}

			if _progress == 1 {
				isFinished = true
			}
		}
	}

	private var _isFinished = false
	/**
	Returns whether the progress is finished.

	The property supports KVO.
	*/
	@IBInspectable public private(set) var isFinished: Bool {
		get {
			if let progressInstance {
				return progressInstance.isFinished
			}

			return _isFinished
		}
		set {
			willChangeValue(for: \.isFinished)
			_isFinished = newValue
			didChangeValue(for: \.isFinished)

			if _isFinished {
				isIndeterminate = false

				if !isCancelled, showCheckmarkAtHundredPercent {
					progressLabel.string = ""
					cancelButton.isHidden = true
					successView.isHidden = false
				}
			}
		}
	}

	/**
	Let a `Progress` instance update the `progress` for you.
	*/
	public var progressInstance: Progress? {
		didSet {
			// TODO: Use `AsyncStream` for all these listeners.
			if let progressInstance {
				progressObserver = progressInstance.observe(\.fractionCompleted) { sender, _ in
					Task { @MainActor [weak self] in
						guard
							let self,
							!self.isCancelled,
							!sender.isFinished
						else {
							return
						}

						self.progress = sender.fractionCompleted
					}
				}

				finishedObserver = progressInstance.observe(\.isFinished) { sender, _ in
					Task { @MainActor [weak self] in
						guard
							let self,
							!self.isCancelled,
							sender.isFinished
						else {
							return
						}

						self.progress = 1
					}
				}

				cancelledObserver = progressInstance.observe(\.isCancelled) { sender, _ in
					Task { @MainActor [weak self] in
						guard let self else {
							return
						}

						self.isCancelled = sender.isCancelled
					}
				}

				indeterminateObserver = progressInstance.observe(\.isIndeterminate) { sender, _ in
					Task { @MainActor [weak self] in
						guard let self else {
							return
						}

						self.isIndeterminate = sender.isIndeterminate
					}
				}

				isCancellable = progressInstance.isCancellable
				isIndeterminate = progressInstance.isIndeterminate
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

	@MainActor
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
		backgroundCircle.animate(\.strokeColor, to: color.withAlphaComponent(0.5), duration: duration)
		progressCircle.animate(\.strokeColor, to: color, duration: duration)
		progressLabel.animate(\.foregroundColor, to: color, duration: duration)
		indeterminateCircle.animate(\.strokeColor, to: color, duration: duration)

		cancelButton.textColor = color
		cancelButton.backgroundColor = color.withAlphaComponent(0.1)
		cancelButton.activeBackgroundColor = color

		successView.color = color

		if indeterminateCircle.animation(forKey: "rotate") == nil {
			indeterminateCircle.add(CABasicAnimation.rotate, forKey: "rotate")
		}
	}

	private func commonInit() {
		wantsLayer = true
		layer?.addSublayer(backgroundCircle)
		layer?.addSublayer(indeterminateCircle)
		layer?.addSublayer(progressCircle)
		layer?.addSublayer(progressLabel)

		addSubview(successView)
		addSubview(cancelButton)

		progressCircle.isHidden = isIndeterminate
		indeterminateCircle.isHidden = !isIndeterminate
		progressLabel.isHidden = isLabelHidden
	}

	/**
	Reset the progress back to zero without animating.
	*/
	public func resetProgress() {
		alphaValue = 1

		_color = originalColor
		_progress = 0

		_isFinished = false
		_isCancelled = false
		isIndeterminate = false

		progressCircle.resetProgress()
		progressLabel.string = "0%"
		progressLabel.isHidden = isLabelHidden

		successView.isHidden = true

		needsDisplay = true
	}

	/**
	Cancels `Progress` if it's set and prevents further updates.
	*/
	public func cancelProgress() {
		guard isCancellable else {
			return
		}

		guard let progressInstance else {
			isCancelled = true
			return
		}

		progressInstance.cancel()
	}

	/**
	Triggers when the progress was cancelled succesfully.
	*/
	public var onCancelled: (() -> Void)?

	private var _isCancellable = false
	/**
	If the progress view is cancellable it shows the cancel button.
	*/
	@IBInspectable public var isCancellable: Bool {
		get {
			if let progressInstance {
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

	The property supports KVO.
	*/
	@IBInspectable public private(set) var isCancelled: Bool {
		get {
			if let progressInstance {
				return progressInstance.isCancelled
			}

			return _isCancelled
		}
		set {
			willChangeValue(for: \.isCancelled)
			_isCancelled = newValue
			didChangeValue(for: \.isCancelled)

			if newValue {
				onCancelled?()
				visualizeCancelledStateIfNecessary()
				isIndeterminate = false
			}
		}
	}

	/**
	Determines whether to visualize changing into the cancelled state.
	*/
	public var visualizeCancelledState = true

	/**
	Supply the base color to use for displaying the cancelled state.
	*/
	public var cancelledStateColorHandler: ((NSColor) -> NSColor)?

	private func visualizeCancelledStateIfNecessary() {
		guard visualizeCancelledState else {
			return
		}

		if let cancelledStateColorHandler {
			_color = cancelledStateColorHandler(originalColor)
		} else {
			_color = originalColor.adjusting(saturation: -0.4, brightness: -0.2)
			alphaValue = 0.7
		}

		needsDisplay = true
	}

	private weak var trackingArea: NSTrackingArea?

	override public func updateTrackingAreas() {
		if let trackingArea {
			removeTrackingArea(trackingArea)
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
		guard window?.isShowingModalOrSheet != true else {
			return
		}

		guard
			isCancellable,
			!isCancelled,
			!isFinished
		else {
			super.mouseEntered(with: event)
			return
		}

		progressLabel.isHidden = true
		cancelButton.fadeIn()
		successView.isHidden = shouldHideSuccessView
	}

	override public func mouseExited(with event: NSEvent) {
		progressLabel.isHidden = _isLabelHidden || (isIndeterminate && progress == 0)
		cancelButton.isHidden = true
		successView.isHidden = shouldHideSuccessView
	}

	private var _isIndeterminate = false
	/**
	Make the progress indeterminate.

	The property supports KVO.
	*/
	@IBInspectable public var isIndeterminate: Bool {
		get {
			if let progressInstance {
				return progressInstance.isIndeterminate
			}

			return _isIndeterminate
		}
		set {
			willChangeValue(for: \.isIndeterminate)
			_isIndeterminate = newValue
			didChangeValue(for: \.isIndeterminate)

			if _isIndeterminate {
				startIndeterminateState()
			} else {
				stopIndeterminateState()
			}
		}
	}

	private func startIndeterminateState() {
		progressCircle.isHidden = true
		indeterminateCircle.isHidden = false
		progressLabel.isHidden = _isLabelHidden || (progress == 0 && isIndeterminate && cancelButton.isHidden)
	}

	private func stopIndeterminateState() {
		indeterminateCircle.isHidden = true
		progressCircle.isHidden = false
		progressLabel.isHidden = _isLabelHidden || !cancelButton.isHidden
	}

	private var _isLabelHidden = false
	/**
	Hide the progress label.

	The property supports KVO.
	*/
	@IBInspectable public var isLabelHidden: Bool {
		get { _isLabelHidden }
		set {
			willChangeValue(for: \.isLabelHidden)
			_isLabelHidden = newValue
			didChangeValue(for: \.isLabelHidden)

			progressLabel.isHidden = _isLabelHidden
		}
	}

	private var shouldHideSuccessView: Bool {
		!showCheckmarkAtHundredPercent || !isFinished || isCancelled
	}
}

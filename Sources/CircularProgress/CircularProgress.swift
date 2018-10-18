import Cocoa

@IBDesignable
public final class CircularProgress: NSView {
	private var lineWidth: Double = 2
	private lazy var radius = bounds.midX * 0.8
	private var _progress: Double = 0
	private var progressObserver: NSKeyValueObservation?

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
		$0.frame = bounds
		$0.fontSize = bounds.width * 0.2
		$0.position.y = bounds.midY * 0.25
		$0.alignmentMode = .center
		$0.font = NSFont.helveticaNeueLight // Not using the system font as it has too much number width variance
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

			progressLabel.string = showCheckmarkAtHundredPercent && _progress == 1 ? "✔" : "\(Int(_progress * 100))%"

			// TODO: Figure out why I need to flush here to get the label to update in `Gifski.app`.
			CATransaction.flush()
		}
	}

	/**
	Let a `Progress` instance update the `progress` for you.
	*/
	public var progressInstance: Progress? {
		didSet {
			if let progressInstance = progressInstance {
				progressObserver = progressInstance.observe(\.fractionCompleted) { sender, _ in
					self.progress = sender.fractionCompleted
				}
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
		backgroundCircle.strokeColor = color.with(alpha: 0.5).cgColor
		progressCircle.strokeColor = color.cgColor
		progressLabel.foregroundColor = color.cgColor
	}

	private func commonInit() {
		wantsLayer = true
		layer?.addSublayer(backgroundCircle)
		layer?.addSublayer(progressCircle)
		layer?.addSublayer(progressLabel)
	}

	/**
	Reset the progress back to zero without animating.
	*/
	public func resetProgress() {
		_progress = 0
		progressCircle.resetProgress()
		progressLabel.string = "0%"
	}
}

import Cocoa

class CheckmarkView: NSView {
	// MARK: - NSView

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		commonInit()
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		commonInit()
	}

	override var isHidden: Bool {
		didSet {
			if isHidden {
				stopAnimation()
			} else {
				startAnimation()
			}
		}
	}

	// MARK: - CheckmarkView

	private let animationDuration: TimeInterval = 0.5

	var color: NSColor = .controlAccentColorPolyfill {
		didSet {
			shapeLayer.strokeColor = color.cgColor
		}
	}

	var lineWidth: CGFloat = 2 {
		didSet {
			shapeLayer.lineWidth = lineWidth
		}
	}

	private func commonInit() {
		wantsLayer = true
		layer?.addSublayer(shapeLayer)
		stopAnimation()
	}

	private lazy var shapeLayer: CAShapeLayer = {
		let scale: CGFloat = 0.4
		let marginScale = (1 - scale) / 2
		let width = bounds.size.width * scale
		let height = bounds.size.height * scale

		let checkmarkPath = NSBezierPath()
		checkmarkPath.move(to: CGPoint(x: 0, y: width / 2))
		checkmarkPath.line(to: CGPoint(x: width / 3, y: width / 6))
		checkmarkPath.line(to: CGPoint(x: width, y: 5 * width / 6))

		let layer = CAShapeLayer()
		layer.frame = CGRect(x: marginScale * bounds.size.width, y: marginScale * bounds.size.height, width: width, height: height)
		layer.path = checkmarkPath.cgPath
		layer.fillColor = nil
		layer.fillMode = .forwards
		layer.lineCap = .round
		layer.lineJoin = .miter
		layer.lineWidth = lineWidth
		layer.strokeColor = color.cgColor
		return layer
	}()

	// MARK: - CheckmarkView (Animation)

	private lazy var animation = with(CAKeyframeAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))) {
		$0.values = [0, 0.333, 1.0]
		$0.duration = animationDuration
		$0.timingFunctions = [
			CAMediaTimingFunction(name: .easeOut),
			CAMediaTimingFunction(name: .easeOut)
		]
	}

	private let animationKey = "checkmarkAnimation"

	private func startAnimation() {
		if shapeLayer.animation(forKey: animationKey) == nil {
			shapeLayer.add(animation, forKey: animationKey)
		}
	}

	private func stopAnimation() {
		shapeLayer.removeAnimation(forKey: animationKey)
	}
}

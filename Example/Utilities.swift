import Cocoa


func delay(seconds: TimeInterval, closure: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}


extension Collection {
	/**
	Returns a infinite sequence with consecutively unique random elements from the collection.

	```
	let x = [1, 2, 3].uniqueRandomElementIterator()

	x.next()
	//=> 2
	x.next()
	//=> 1

	for element in x.prefix(2) {
		print(element)
	}
	//=> 3
	//=> 1
	```
	*/
	func uniqueRandomElementIterator() -> AnyIterator<Element> {
		var previousNumber: Int?

		return AnyIterator {
			var offset: Int
			repeat {
				offset = Int.random(in: 0..<count)
			} while offset == previousNumber
			previousNumber = offset

			return self[index(startIndex, offsetBy: offset)]
		}
	}
}


extension NSColor {
	static let systemColors: Set<NSColor> = [
		.systemBlue,
		.systemBrown,
		.systemGray,
		.systemGreen,
		.systemOrange,
		.systemPink,
		.systemPurple,
		.systemRed,
		.systemYellow
	]

	private static let uniqueRandomSystemColors = systemColors.uniqueRandomElementIterator()

	static func uniqueRandomSystemColor() -> NSColor { uniqueRandomSystemColors.next()! }
}


extension CGRect {
	/**
	Returns a CGRect where `self` is centered in `rect`.
	*/
	func centered(in rect: Self, xOffset: Double = 0, yOffset: Double = 0) -> Self {
		Self(
			x: ((rect.width - size.width) / 2) + CGFloat(xOffset),
			y: ((rect.height - size.height) / 2) + CGFloat(yOffset),
			width: size.width,
			height: size.height
		)
	}
}


extension NSView {
	/**
	- Note: You should almost never need to set `appearanceName` as it's done automatically.
	*/
	@discardableResult
	func insertVibrancyView(
		material: NSVisualEffectView.Material,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		appearanceName: NSAppearance.Name? = nil
	) -> NSVisualEffectView {
		let view = NSVisualEffectView(frame: bounds)
		view.autoresizingMask = [.width, .height]
		view.material = material
		view.blendingMode = blendingMode

		if let appearanceName = appearanceName {
			view.appearance = NSAppearance(named: appearanceName)
		}

		addSubview(view, positioned: .below, relativeTo: nil)

		return view
	}
}


extension NSWindow {
	func makeVibrant() {
		if #available(macOS 10.14, *) {
			contentView?.insertVibrancyView(material: .underWindowBackground)
		}
	}
}

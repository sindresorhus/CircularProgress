import Cocoa


func delay(seconds: TimeInterval, closure: @escaping () -> Void) {
	DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}


extension CGRect {
	/**
	Returns a CGRect where `self` is centered in `rect`
	*/
	func centered(in rect: CGRect, xOffset: Double = 0, yOffset: Double = 0) -> CGRect {
		return CGRect(
			x: ((rect.width - size.width) / 2) + CGFloat(xOffset),
			y: ((rect.height - size.height) / 2) + CGFloat(yOffset),
			width: size.width,
			height: size.height
		)
	}
}


extension NSView {
	/**
	- Note: You should almost never need to set `appearanceName` as it's done automatically
	*/
	@discardableResult
	func insertVibrancyView(
		material: NSVisualEffectView.Material = .appearanceBased,
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

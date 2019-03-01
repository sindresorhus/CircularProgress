# CircularProgress

> Circular progress indicator for your macOS app

<img src="screenshot.gif" width="834">

This package is used in production by the [Gifski](https://github.com/sindresorhus/gifski-app) and [HEIC Converter](https://sindresorhus.com/heic-converter) app.


## Requirements

- macOS 10.12+
- Xcode 10+
- Swift 4.2+


## Install

#### SwiftPM

```swift
.package(url: "https://github.com/sindresorhus/CircularProgress", from: "0.2.1")
```

#### Carthage

```
github "sindresorhus/CircularProgress"
```

#### CocoaPods

```ruby
pod 'CircularProgressMac'
```

<a href="https://www.patreon.com/sindresorhus">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>


## Usage

Also check out the example app in the Xcode project.

### Manually set the progress

```swift
import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	let circularProgress = CircularProgress(size: 200)

	func applicationDidFinishLaunching(_ notification: Notification) {
		window.contentView!.addSubview(circularProgress)

		foo.onUpdate = { progress in
			self.circularProgress.progress = progress
		}
	}
}
```

### Specify a [`Progress`](https://developer.apple.com/documentation/foundation/progress) instance

```swift
import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!

	let progress = Progress(totalUnitCount: 1)

	func applicationDidFinishLaunching(_ notification: Notification) {
		window.contentView!.addSubview(circularProgress)

		progress?.becomeCurrent(withPendingUnitCount: 1)
		circularProgress.progressInstance = progress
	}
}
```

### Cancel button

<img src="screenshot-cancel.gif" width="300" align="right">

If you use the `.progress` property, you need to opt into the cancel button by setting `.isCancellable = true`. You can be notified of when the button is clicked by setting the `.onCancelled` property to a closure.

If you use the `.progressInstance` property, setting a `Progress` object that is [`isCancellable`](https://developer.apple.com/documentation/foundation/progress/1409348-iscancellable), which is the default, automatically enables the cancel button.

<img src="screenshot-desaturate.gif" width="111" align="right">

Per default, the cancelled state is indicated by desaturing the current color and reducing the opacity. You can customize this by implementing the `.cancelledStateColorHandler` callback and returning a color to use for the cancelled state instead. The opacity is not automatically reduced when the callback has been set. To disable the cancelled state visualization entirely, set `.visualizeCancelledState` to `false`.

### Indeterminate state

<img src="screenshot-indeterminate.gif" width="118" align="right">

Displays a state that indicates that the remaining progress is indeterminate.

Note that the `.progress` property and `.isIndeterminate` are not tied together. You'll need to manually set `.isIndeterminate = false` when progress is being made again.

If you use the `.progressInstance` property, the [`isIndeterminate`](https://developer.apple.com/documentation/foundation/progress/1412871-isindeterminate) property will automatically be observed. The view will then switch back and forth to the indeterminate state when appropriate.

## API

```swift
/**
Color of the circular progress view.

Defaults to the user's accent color. For High Sierra and below it uses a fallback color.
*/
@IBInspectable var color: NSColor = .controlAccentColor

/**
Show `✔` instead `100%`.
*/
@IBInspectable var showCheckmarkAtHundredPercent: Bool = true

/**
The progress value in the range `0...1`.

- Note: The value will be clamped to `0...1`.
- Note: Can be set from a background thread.
*/
@IBInspectable var progress: Double = 0

/**
Let a `Progress` instance update the `progress` for you.
*/
var progressInstance: Progress?

/**
Reset the progress back to zero without animating.
*/
func resetProgress() {}

/**
Cancels `Progress` if it's set and prevents further updates.
*/
func cancelProgress() {}

/**
Triggers when the progress was cancelled succesfully.
*/
var onCancelled: (() -> Void)?

/**
Returns whether the progress is finished.
*/
@IBInspectable private(set) var isFinished: Bool

/**
If the progress view is cancellable it shows the cancel button.
*/
@IBInspectable var isCancellable: Bool

/**
Displays the indeterminate state.
*/
@IBInspectable public var isIndeterminate: Bool

/**
Returns whether the progress has been cancelled.
*/
@IBInspectable private(set) var isCancelled: Bool

/**
Determines whether to visualize changing into the cancelled state.
*/
public var visualizeCancelledState: Bool = true

/**
Supply the base color to use for displaying the cancelled state.
*/
public var cancelledStateColorHandler: ((NSColor) -> NSColor)?

init(frame: CGRect) {}
init?(coder: NSCoder) {}

/**
Initialize the progress view with a width/height of the given `size`.
*/
convenience init(size: Double) {}
```


## Related

- [DockProgress](https://github.com/sindresorhus/DockProgress) - Show progress in your app's Dock icon
- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [Preferences](https://github.com/sindresorhus/Preferences) - Add a preferences window to your macOS app
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin) - Add "Launch at Login" functionality to your macOS app
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)

You might also like my [apps](https://sindresorhus.com/apps).


## License

MIT © [Sindre Sorhus](https://sindresorhus.com)

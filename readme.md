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
.package(url: "https://github.com/sindresorhus/CircularProgress", from: "0.1.3")
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

Setting a `Progress` object that `isCancellable` automatically enables the cancel button.

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

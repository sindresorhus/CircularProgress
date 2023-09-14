// swift-tools-version:5.9
import PackageDescription

let package = Package(
	name: "CircularProgress",
	platforms: [
		.macOS(.v10_15)
	],
	products: [
		.library(
			name: "CircularProgress",
			targets: [
				"CircularProgress"
			]
		)
	],
	targets: [
		.target(
			name: "CircularProgress"
		)
	]
)

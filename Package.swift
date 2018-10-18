// swift-tools-version:4.2
import PackageDescription

let package = Package(
	name: "CircularProgress",
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

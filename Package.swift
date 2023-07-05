// swift-tools-version:5.3

import Foundation
import PackageDescription

let package = Package(
	name: "Nand7400Asm",
	platforms: [
		.iOS(.v13),
		.macOS(.v11),
	],
	products: [
		.library(
			name: "Nand7400Asm",
			targets: [
				"Nand7400Asm"
			]
		)
	],
	targets: [
		// .target(
		// 	name: "Nand7400Asm",
		// 	dependencies: ["Nand7400AsmRust"]
		// ),
		.binaryTarget(
			name: "Nand7400Asm",
			url:
				"https://github.com/cogsandsquigs/nand7400-asm/releases/download/0.0.0-0/bundle.zip",
			checksum: "789735c3609cff13b62bde42478a05ab445be02defcab832a90d635c5e3d5967"
		)
		// .testTarget(
		// 	name: "Nand7400AsmTests",
		// 	dependencies: ["Nand7400Asm"]
		// ),
	]
)

// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TagAlong",
	 platforms: [
				 .macOS(.v14),
				 .iOS(.v17),
				 .watchOS(.v10)
		  ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TagAlong",
            targets: ["TagAlong"]),
        .library(
            name: "TagAlongCloudKit",
            targets: ["TagAlongCloudKit"]),
    ],
	 dependencies: [
		.package(url: "https://github.com/ios-tooling/cloudseeding", from: "0.1.6"),
	 ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "TagAlong", dependencies: []),
        .target(name: "TagAlongCloudKit", dependencies: [
            "TagAlong",
            .product(name: "CloudSeeding", package: "cloudseeding"),
        ]),
//        .testTarget(
//            name: "TagAlongTests",
//            dependencies: ["TagAlong"]),
    ]
)

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "ChouTiTest",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .visionOS(.v1),
    .watchOS(.v7),
  ],
  products: [
    .library(name: "ChouTiTest", targets: ["ChouTiTest"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "ChouTiTest",
      dependencies: []
    ),
    .testTarget(
      name: "ChouTiTestTests",
      dependencies: [
        "ChouTiTest",
      ]
    ),
  ]
)

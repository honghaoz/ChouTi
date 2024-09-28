// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "ChouTi",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .watchOS(.v7),
  ],
  products: [
    .library(name: "ChouTi", targets: ["ChouTi"]),
  ],
  dependencies: [
    .package(path: "../ChouTiTest"),
  ],
  targets: [
    .target(
      name: "ChouTi",
      dependencies: []
    ),
    .testTarget(
      name: "ChouTiTests",
      dependencies: [
        "ChouTi",
        "ChouTiTest",
      ]
    ),
  ]
)

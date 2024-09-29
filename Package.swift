// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "ChouTi",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13),
    .tvOS(.v13),
    .visionOS(.v1),
    .watchOS(.v7),
  ],
  products: [
    .library(name: "ChouTi", targets: ["ChouTi"]),
    .library(name: "ChouTiTest", targets: ["ChouTiTest"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "ChouTi", dependencies: [], path: "packages/ChouTi/Sources"),
    .target(name: "ChouTiTest", dependencies: [], path: "packages/ChouTiTest/Sources"),
  ]
)

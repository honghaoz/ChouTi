// swift-tools-version: 5.8

import PackageDescription

let package = Package(
  name: "ChouTi",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "ChouTiTest", targets: ["ChouTiTest"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "ChouTiTest", dependencies: [], path: "packages/ChouTiTest/Sources"),
  ]
)

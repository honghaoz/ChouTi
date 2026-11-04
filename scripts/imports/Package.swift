// swift-tools-version: 5.9

import PackageDescription

// The tests of the import grouping's logic, `ImportGroups.swift`, which `group-imports.sh` compiles with its entry
// point, `group-imports.swift`. The logic is compiled into the test target, as it's a script's, not a module's.
let package = Package(
  name: "ImportGroups",
  platforms: [
    .macOS(.v10_15),
  ],
  dependencies: [
    .package(path: "../../packages/ChouTiTest"),
  ],
  targets: [
    .testTarget(
      name: "ImportGroupsTests",
      dependencies: [
        "ChouTiTest",
      ],
      path: ".",
      exclude: [
        "group-imports.sh",
        "group-imports.swift",
      ],
      sources: [
        "ImportGroups.swift",
        "ImportGroupsTests.swift",
      ]
    ),
  ]
)

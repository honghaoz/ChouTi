# ChouTiT

[![codecov](https://codecov.io/github/honghaoz/ChouTi/branch/master/graph/badge.svg?token=BWWP0ROG2A&flag=ChouTi&&precision=2)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTi%2FSources?flags%5B0%5D=ChouTi&displayType=list)

**ChouTi** is a Swift framework that provides core extensions and utilities to enhance development on iOS and macOS.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
  // add the package to your package dependencies
  .package(url: "https://github.com/honghaoz/ChouTi", from: "0.0.2"),
],
targets: [
  // add ChouTi to your target dependencies
  .target(
    name: "MyTarget",
    dependencies: [
      .product(name: "ChouTi", package: "ChouTi"),
    ]
  ),
]
```

## Usage

```swift
import ChouTi

...
```

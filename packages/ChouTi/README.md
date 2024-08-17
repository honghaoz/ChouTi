# ChouTi

[![codecov](https://img.shields.io/codecov/c/github/honghaoz/ChouTi/master?token=BWWP0ROG2A&flag=ChouTi&style=flat&label=code%20coverage&color=59B31D)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTi%2FSources?flags%5B0%5D=ChouTi&displayType=list)

**ChouTi** is a Swift framework that provides common utilities and extensions to enhance development on iOS and macOS.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
  // add the package to your package dependencies
  .package(url: "https://github.com/honghaoz/ChouTi", from: "0.0.5"),
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

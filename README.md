# ChouTi

[![build](https://github.com/honghaoz/ChouTi/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/honghaoz/ChouTi/actions/workflows/build.yml?query=branch%3Amaster)
![swift](https://img.shields.io/badge/swift-5.9-F05138.svg)
![platforms](https://img.shields.io/badge/platforms-macOS%2010.15%20%7C%20iOS%2013.0%20%7C%20tvOS%2013.0%20%7C%20visionOS%201.0%20%7C%20watchOS%207.0-007fea.svg)

**ChouTi** is a repository of Swift packages that provides frameworks, utilities and extensions to enhance development on Apple platforms.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
  // add the package to your package dependencies
  .package(url: "https://github.com/honghaoz/ChouTi", from: "0.0.9"),
],
targets: [
  // add products to your target dependencies
  .target(
    name: "MyTarget",
    dependencies: [
      .product(name: "ChouTi", package: "ChouTi"),
    ]
  ),
  .testTarget(
    name: "MyTargetTests",
    dependencies: [
      .product(name: "ChouTiTest", package: "ChouTi"),
    ]
  ),
]
```

## Packages

### ChouTi

[![codecov](https://img.shields.io/codecov/c/github/honghaoz/ChouTi/master?token=BWWP0ROG2A&flag=ChouTi&style=flat&label=code%20coverage&color=59B31D)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTi%2FSources?flags%5B0%5D=ChouTi&displayType=list)

[**ChouTi**](packages/ChouTi) is a Swift framework that provides common utilities and extensions to enhance development on Apple platforms.

```swift
import ChouTi

...
```

### ChouTiTest

[![codecov](https://img.shields.io/codecov/c/github/honghaoz/ChouTi/master?token=BWWP0ROG2A&flag=ChouTiTest&style=flat&label=code%20coverage&color=59B31D)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTiTest%2FSources?flags%5B0%5D=ChouTiTest&displayType=list)

[**ChouTiTest**](packages/ChouTiTest) is a Swift testing framework for writing tests with simple, expressive syntax.

```swift
import ChouTiTest

class SomeTests: XCTestCase {

  func testExample() throws {

    // boolean
    expect(expression).to(beTrue())
    expect(expression) == true
    expect(expression).to(beFalse())
    expect(expression) == false
    expect(expression).toNot(beTrue())
    expect(expression) != true

    // collection
    expect(expression).to(beEmpty())
    expect(expression).toNot(beEmpty())

    // equal
    expect(expression).to(beEqual(to: 2))
    expect(expression) == 2
    expect(expression).toNot(beEqual(to: 2))
    expect(expression) != 2
    expect(expression).to(beApproximatelyEqual(to: 2, within: 1e-6))
    expect(expression).toNot(beApproximatelyEqual(to: 2, within: 1e-6))

    // identical
    expect(expression).to(beIdentical(to: object))
    expect(expression) === object

    // nil
    expect(expression).to(beNil())
    expect(expression) == nil
    expect(expression).toNot(beNil())
    expect(expression) != nil

    // unwrap
    try expect(unwrap(expression)) == expectedValue

    // error
    expect(try expression()).to(throwError(SomeError.error))
    expect(try expression()).toNot(throwError(SomeError.error))

    // error type
    expect(try expression()).to(throwErrorOfType(SomeError.self))

    // any error
    expect(try expression()).to(throwAnError())

    // eventually
    expect(expression).toEventually(beTrue())
    expect(expression).toEventually(beEmpty())
    expect(expression).toEventually(beEqual(to: 2))
    expect(expression).toEventually(beIdentical(to: object))

    expect(expression).toEventuallyNot(beTrue())
    expect(expression).toEventuallyNot(beEmpty())
  }
}
```

## License

ChouTi is available under the MIT license. See the [LICENSE](https://github.com/honghaoz/ChouTi/blob/master/LICENSE) file for more info.

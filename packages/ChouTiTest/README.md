# ChouTiTest

[![codecov](https://img.shields.io/codecov/c/github/honghaoz/ChouTi/master?token=BWWP0ROG2A&flag=ChouTiTest&style=flat&label=code%20coverage&color=59B31D)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTiTest%2FSources?flags%5B0%5D=ChouTiTest&displayType=list)

**ChouTiTest** is a Swift testing framework for writing tests with simple, expressive syntax.

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
  // add the package to your package dependencies
  .package(url: "https://github.com/honghaoz/ChouTi", from: "0.0.10"),
],
targets: [
  // add ChouTiTest to your test target dependencies
  .testTarget(
    name: "MyTargetTests",
    dependencies: [
      .product(name: "ChouTiTest", package: "ChouTi"),
    ]
  ),
]
```

## Usage

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
    expect(try expression()).toNot(throwErrorOfType(SomeError.self))

    // any error
    expect(try expression()).to(throwAnError())
    expect(try expression()).toNot(throwAnError())

    // eventually
    expect(expression).toEventually(beTrue())
    expect(expression).toEventually(beEmpty())
    expect(expression).toEventually(beEqual(to: 2))
    expect(expression).toEventually(beIdentical(to: object))
    expect(expression).toEventually(beNil())
    expect(try expression()).toEventually(throwError(SomeError.error))
    expect(try expression()).toEventually(throwErrorOfType(SomeError.self))
    expect(try expression()).toEventually(throwAnError())

    expect(expression).toEventuallyNot(beTrue())
    expect(expression).toEventuallyNot(beEmpty())
    expect(expression).toEventuallyNot(beEqual(to: 2))
    expect(expression).toEventuallyNot(beIdentical(to: object))
    expect(expression).toEventuallyNot(beNil())
    expect(try expression()).toEventuallyNot(throwError(SomeError.error))
    expect(try expression()).toEventuallyNot(throwErrorOfType(SomeError.self))
    expect(try expression()).toEventuallyNot(throwAnError())
  }
}
```

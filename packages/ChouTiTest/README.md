# ChouTiTest

[![codecov](https://codecov.io/github/honghaoz/ChouTi/branch/master/graph/badge.svg?token=BWWP0ROG2A&flag=ChouTiTest&&precision=2)](https://codecov.io/github/honghaoz/ChouTi/tree/master/packages%2FChouTiTest%2FSources?flags%5B0%5D=ChouTiTest&displayType=list)

## Overview

A testing framework.

Write tests with a simple and expressive syntax.

```swift
import XCTest
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
    expect(try expression()).to(throwSomeError())
  }
}
```

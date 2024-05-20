//
//  LogMessageTests.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

@testable import ChouTi

class LogMessageTests: XCTestCase {

  func testSimpleString() {
    let message: LogMessage = "test"
    expect(message.materializedString()) == "test"
  }

  func testNumberInterpolation() {
    let message: LogMessage = "test: \(123)"
    expect(message.materializedString()) == "test: 123"
  }

  func testStringInterpolation() {
    let message: LogMessage = "test: \("hey there")"
    expect(message.materializedString()) == "test: hey there"
  }

  func testClassInterpolation() {
    class Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo)"
    let string = "test: \(foo)"
    expect(message.materializedString()) == string
  }

  func testStructInterpolation() {
    struct Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo)"
    let string = "test: \(foo)"
    expect(message.materializedString()) == string
  }

  func testPrivacyInterpolation() {
    struct Foo {
      let bar: [String] = ["yes"]
    }

    let foo = Foo()
    let message: LogMessage = "test: \(foo, privacy: .private)"
    expect(message.materializedString()) == "test: <private>"
  }

  func testDefault() {
    let nilValue: Int? = nil
    let message: LogMessage = "test: \(nilValue, default: "default")"
    expect(message.materializedString()) == "test: default"
  }
}

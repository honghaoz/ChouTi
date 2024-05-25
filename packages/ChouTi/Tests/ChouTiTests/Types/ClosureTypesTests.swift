//
//  ClosureTypesTests.swift
//
//  Created by Honghao Zhang on 5/19/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

final class TypeAliasTests: XCTestCase {

  // Test BlockVoid
  func testBlockVoid() {
    let block: BlockVoid = {}
    block()
  }

  // Test BlockThrowsVoid
  func testBlockThrowsVoid() {
    let block: BlockThrowsVoid = {}
    expect(try block()).toNot(throwAnError())
  }

  // Test BlockAsyncVoid
  func testBlockAsyncVoid() async {
    let block: BlockAsyncVoid = {}
    await block()
  }

  // Test BlockAsyncThrowsVoid
  func testBlockAsyncThrowsVoid() async {
    let block: BlockAsyncThrowsVoid = {
      try await Task.sleep(nanoseconds: 1)
    }
    do {
      try await block()
    } catch {}
  }

  // Test BlockBool
  func testBlockBool() {
    var result = false
    let block: BlockBool = { parameter in
      result = parameter
    }
    block(true)
    expect(result) == true
  }

  // Test BlockThrowsBool
  func testBlockThrowsBool() {
    var result = false
    let block: BlockThrowsBool = { parameter in
      result = parameter
    }
    expect(try block(true)).toNot(throwAnError())
    expect(result) == true
  }
}

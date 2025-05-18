//
//  CancellableTokenTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/5/23.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import ChouTiTest

import ChouTi

final class CancellableTokenTests: XCTestCase {

  private final class TestToken: NSObject, CancellableToken {

    private(set) var isCancelled = false

    func cancel() {
      isCancelled = true
    }
  }

  func testCancel() {
    let token = TestToken()
    expect(token.isCancelled) == false
    token.cancel()
    expect(token.isCancelled) == true
  }

  func testStoreInCollection() {
    var collection: [TestToken] = []
    let token = TestToken()
    token.store(in: &collection)
    expect(collection.count) == 1
    expect(collection.first) === token
  }

  func testStoreInArray() {
    var array: [CancellableToken] = []
    let token = TestToken()
    token.store(in: &array)
    expect(array.count) == 1
    expect(array.first as? TestToken) === token
  }

  func testStoreInDictionary() {
    var dictionary = [ObjectIdentifier: TestToken]()
    let token = TestToken()
    token.store(in: &dictionary)
    expect(dictionary.count) == 1
    expect(dictionary[ObjectIdentifier(token)]) === token

    token.remove(from: &dictionary)
    expect(dictionary.count) == 0
  }

  func testStoreInOrderedDictionary() {
    var dictionary = OrderedDictionary<ObjectIdentifier, TestToken>()
    let token = TestToken()
    token.store(in: &dictionary)
    expect(dictionary.count) == 1
    expect(dictionary[ObjectIdentifier(token)]) === token
  }

  func testRemoveFromOrderedDictionary() {
    var dictionary = OrderedDictionary<ObjectIdentifier, TestToken>()
    let token = TestToken()
    token.store(in: &dictionary)
    token.remove(from: &dictionary)
    expect(dictionary.count) == 0
  }

  func testStoreInSet() {
    var set: Set<TestToken> = []
    let token = TestToken()
    token.store(in: &set)
    expect(set.count) == 1
    expect(set.contains(token)) == true
  }
}

final class CancellableTokenGroupTests: XCTestCase {

  static var cancelIndex: Int = 0

  private final class TestToken: CancellableToken {

    private(set) var isCancelled = false
    private(set) var cancelIndex: Int = 0

    func cancel() {
      isCancelled = true
      CancellableTokenGroupTests.cancelIndex += 1
      cancelIndex = CancellableTokenGroupTests.cancelIndex
    }
  }

  func testTokenGroupCancel() {
    let token1 = TestToken()
    let token2 = TestToken()
    let tokenGroup = CancellableTokenGroup(tokens: [token1, token2], cancel: { _ in })
    expect(token1.isCancelled) == false
    expect(token2.isCancelled) == false

    tokenGroup.cancel()

    expect(token1.isCancelled) == true
    expect(token2.isCancelled) == true
    expect(token1.cancelIndex) == 1
    expect(token2.cancelIndex) == 2

    let pattern = #"CancellableTokenGroup\(0x[0-9a-fA-F]+\)"#
    expect(tokenGroup.description.range(of: pattern, options: .regularExpression)) != nil
  }
}

final class ValueCancellableTokenTests: XCTestCase {

  func test() {
    var isCancelled = false
    let token = ValueCancellableToken(value: "Test") { _ in
      isCancelled = true
    }
    expect(token.value) == "Test"
    expect(isCancelled) == false
    token.cancel()
    expect(isCancelled) == true

    let pattern = #"ValueCancellableToken<String>\(0x[0-9a-fA-F]+\)"#
    expect(token.description.range(of: pattern, options: .regularExpression), "\(token.description)") != nil
  }

  func test_cancelOnDeallocate() {
    var isCancelled = false
    var token: ValueCancellableToken? = ValueCancellableToken(value: "Test") { _ in
      isCancelled = true
    }
    _ = token
    expect(isCancelled) == false
    token = nil
    expect(isCancelled) == true
  }

  func test_cancelOnDeallocate_false() {
    var isCancelled = false
    var token: ValueCancellableToken? = ValueCancellableToken(value: "Test", cancelOnDeallocate: false) { _ in
      isCancelled = true
    }
    _ = token
    expect(isCancelled) == false
    token = nil
    expect(isCancelled) == false
  }
}

final class SimpleCancellableTokenTests: XCTestCase {

  func test_cancel() {
    var isCancelled = false
    let token = SimpleCancellableToken { _ in
      isCancelled = true
    }
    expect(isCancelled) == false
    token.cancel()
    expect(isCancelled) == true
  }

  func test_cancelOnDeallocate() {
    var isCancelled = false
    var token: SimpleCancellableToken! = SimpleCancellableToken(cancelOnDeallocate: true) { _ in
      isCancelled = true
    }
    _ = token
    expect(isCancelled) == false
    token = nil
    expect(isCancelled) == true
  }

  func test_cancelOnDeallocate_false() {
    var isCancelled = false
    var token: SimpleCancellableToken! = SimpleCancellableToken(cancelOnDeallocate: false) { _ in
      isCancelled = true
    }
    _ = token
    expect(isCancelled) == false
    token = nil
    expect(isCancelled) == false
  }

  func test_description() {
    let token = SimpleCancellableToken { _ in }
    expect(token.description) == "SimpleCancellableToken(\(ChouTi.rawPointer(token)))"
  }
}

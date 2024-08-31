//
//  EncryptTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/7/20.
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

import ChouTi
import ChouTiTest
import CryptoKit

class EncryptTests: XCTestCase {

  func testBasicEncryptionDecryption() throws {
    let content = "Hey"
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    let content2 = try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    expect(content) == content2
  }

  func testEmptyString() throws {
    let content = ""
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    let content2 = try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    expect(content) == content2
  }

  func testLongString() throws {
    let content = String(repeating: "Lorem ipsum dolor sit amet. ", count: 100)
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    let content2 = try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    expect(content) == content2
  }

  func testUnicodeCharacters() throws {
    let content = "Hello, 世界! 🌍🌎🌏"
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    let content2 = try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    expect(content) == content2
  }

  func testDifferentKeys() throws {
    let content = "Secret message"
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
    if #available(macOS 14.4, tvOS 17.4, *) {
      expect(
        try decrypt(encryptedData: data, xiaoyi: "bb", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
      ).to(
        throwError(CryptoKitError.authenticationFailure)
      )
    } else {
      do {
        _ = try decrypt(encryptedData: data, xiaoyi: "bb", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
      } catch {
        expect(error.localizedDescription) == "The operation couldn’t be completed. (CryptoKit.CryptoKitError error 3.)"
      }
    }
  }

  func testIncorrectEncryptionKey() throws {
    let content = "Secret message"
    expect(
      try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffff")
    ).to(
      throwError(EncryptError.invalidXiaoyiFormat)
    )
  }

  func testIncorrectDecryptionKey() throws {
    let content = "Secret message"
    let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")

    expect(
      try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "wrong_key")
    ).to(
      throwError(EncryptError.invalidXiaoyiFormat)
    )
  }

  func testInvalidEncryptedData() {
    let invalidData = Data("This is not valid encrypted data".utf8)
    if #available(macOS 14.4, tvOS 17.4, *) {
      expect(
        try decrypt(encryptedData: invalidData, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
      ).to(
        throwError(CryptoKitError.authenticationFailure)
      )
    } else {
      do {
        _ = try decrypt(encryptedData: invalidData, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
      } catch {
        expect(error.localizedDescription) == "The operation couldn’t be completed. (CryptoKit.CryptoKitError error 3.)"
      }
    }
  }

  func testPerformance() {
    let content = String(repeating: "Performance test. ", count: 1000)
    measure {
      do {
        let data = try encrypt(content: content, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
        _ = try decrypt(encryptedData: data, xiaoyi: "aa", "bbbbb", "cccccc", "dddddd", "eeeeee", "fffffff")
      } catch {
        fail(error.localizedDescription)
      }
    }
  }
}
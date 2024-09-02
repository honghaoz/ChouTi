//
//  Data+Hash.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/11/21.
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

import CryptoKit
import Foundation

public extension Data {

  /// Get MD5 checksum.
  ///
  /// - Returns: The MD5 checksum of the data.
  func md5() -> String {
    let digest = Insecure.MD5.hash(data: self)
    let digestString = digest.map { String(format: "%02hhx", $0) }.joined()
    return digestString
  }

  /// Get SHA1 hash.
  ///
  /// - Returns: The SHA1 hash of the data.
  func sha1() -> String {
    let digest = Insecure.SHA1.hash(data: self)
    let digestString = digest.map { String(format: "%02hhx", $0) }.joined()
    return digestString
  }

  /// Get SHA256 hash.
  ///
  /// - Returns: The SHA256 hash of the data.
  func sha256() -> String {
    let digest = SHA256.hash(data: self)
    let digestString = digest.compactMap { String(format: "%02x", $0) }.joined()
    return digestString
  }

  /// Get SHA512 hash.
  ///
  /// - Returns: The SHA512 hash of the data.
  func sha512() -> String {
    let digest = SHA512.hash(data: self)
    let digestString = digest.compactMap { String(format: "%02x", $0) }.joined()
    return digestString
  }
}

/// Readings:
/// - https://blog.cadre.net/encoding-hashing-and-encryption-whats-the-difference

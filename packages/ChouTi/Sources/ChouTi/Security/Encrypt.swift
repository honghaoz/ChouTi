//
//  Encrypt.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/7/20.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

public enum EncryptError: Error {
  case invalidXiaoyiFormat
}

/// Encrypt a string with a key.
///
/// Example:
/// ```
/// let encryptedString = try encrypt(content: content, xiaoyi: "1234567890", "1234567890", "1234567890", "12").base64EncodedString()
/// ```
///
/// - Parameters:
///   - content: The content string to be hide.
///   - xiaoyi: An encrypt key.
/// - Throws: An error if fail to get the data.
/// - Returns: An encrypted data.
public func encrypt(content: String, xiaoyi: String...) throws -> Data {
  let joined = xiaoyi.joined(separator: "")
  guard joined.count == 32 else {
    throw EncryptError.invalidXiaoyiFormat
  }
  let data = Data(joined.utf8)
  let mimi = SymmetricKey(data: data)

  let contentData = Data(content.utf8)
  let encryptedData = try ChaChaPoly.seal(contentData, using: mimi).combined
  return encryptedData
}

/// Decrypt the string from the data.
///
/// Example:
/// ```
/// try decrypt(encryptedData: base64String.base64DecodedData()!, xiaoyi: "1234567890", "1234567890", "1234567890", "12")
/// ```
///
/// - Parameters:
///   - encryptedData: The encrypted data.
///   - xiaoyi: An encrypt key.
/// - Throws: An error if fail to get the original string.
/// - Returns: The decrypted string.
public func decrypt(encryptedData: Data, xiaoyi: String...) throws -> String {
  let joined = xiaoyi.joined(separator: "")
  guard joined.count == 32 else {
    throw EncryptError.invalidXiaoyiFormat
  }
  let data = Data(joined.utf8)
  let mimi = SymmetricKey(data: data)

  let sealedBox = try ChaChaPoly.SealedBox(combined: encryptedData)
  let decryptedData = try ChaChaPoly.open(sealedBox, using: mimi)

  return String(decoding: decryptedData, as: UTF8.self)
}

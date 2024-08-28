//
//  Encrypt.swift
//
//  Created by Honghao Zhang on 6/7/20.
//  Copyright © 2024 ChouTi. All rights reserved.
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

//
//  DeallocationNotifiable.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/3/23.
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

import Foundation

/// A type that can call blocks when it deallocates.
public protocol DeallocationNotifiable: AnyObject {

  /// Add a block to be called when the host object deallocates.
  ///
  /// The last added block will be called first when the host object deallocates.
  ///
  /// - Parameter block: The block to be called when the host object deallocates.
  /// - Returns: A token that can be used to cancel the deallocation block.
  @discardableResult
  func onDeallocate(_ block: @escaping BlockVoid) -> CancellableToken
}

public extension DeallocationNotifiable {

  @discardableResult
  func onDeallocate(_ block: @escaping BlockVoid) -> CancellableToken {
    let tokenManager = tokenManager
    let token = Token(manager: tokenManager, block: block)
    tokenManager.add(token)
    return token
  }
}

extension NSObject: DeallocationNotifiable {}

// MARK: - Private

private enum AssociateKey {
  static var tokenManagerKey: UInt8 = 0
}

private extension DeallocationNotifiable {

  private var tokenManager: TokenManager {
    if let manager = objc_getAssociatedObject(self, &AssociateKey.tokenManagerKey) as? TokenManager {
      return manager
    }

    let manager = TokenManager()
    objc_setAssociatedObject(self, &AssociateKey.tokenManagerKey, manager, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return manager
  }
}

private final class TokenManager {

  private lazy var tokens = OrderedDictionary<ObjectIdentifier, Token>()

  init() {}

  deinit {
    tokens.values.forEach { $0.block() }
  }

  func add(_ token: Token) {
    tokens.insert(value: token, forKey: ObjectIdentifier(token), atIndex: 0)
  }

  func remove(_ token: Token) {
    tokens.removeValue(forKey: ObjectIdentifier(token))
  }
}

private final class Token: CancellableToken {

  weak var manager: TokenManager?
  let block: BlockVoid

  init(manager: TokenManager, block: @escaping BlockVoid) {
    self.manager = manager
    self.block = block
  }

  func cancel() {
    manager?.remove(self)
  }
}

/// https://stackoverflow.com/questions/17678298/how-does-objc-setassociatedobject-work
/// https://juejin.cn/post/6990330990463827981
/// https://stackoverflow.com/questions/15276901/how-do-i-release-properties-that-are-added-at-runtime-in-a-category

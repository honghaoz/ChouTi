//
//  KVOObserver.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2/1/15.
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

/// An KVO observer type.
public protocol KVOObserverType {

  /// Pauses the KVO observation.
  func pause()

  /// Resumes the KVO observation.
  func resume()

  /// Stops the KVO observation.
  func stop()
}

/// A KVO observer that observes a specific object for a given key path and calls a handler with the old and new values.
///
/// For most cases, you don't need to call `stop()`. But when possible, it's a good idea to clean
/// the observations. Read more: https://fpotter.org/posts/when-is-kvo-unregistration-automatic#unexpectedly-autonotifying
///
/// For observing `RawRepresentable` types such as enum types, check out [NSObject.observe(keyPath:withHandler:)](x-source-tag://NSObject.observe_RawRepresentable).
///
/// Example:
/// ```swift
/// // keep a strong reference to the observer
/// private var observer: KVOObserverType?
///
/// // set up the observer
/// observer = KVOObserver<UIScrollView, CGPoint>(object: scrollView, keyPath: "contentOffset") { [weak self] object, old, new in
///   ...
/// }
///
/// // stop the observer when needed, such as in deinit:
/// observer.stop()
/// ```
public final class KVOObserver<Object: AnyObject, T>: NSObject, KVOObserverType {

  public typealias KVOObserverHandler = (_ object: Object, _ old: T, _ new: T) -> Void

  private var observationContext: UInt8 = 0

  /// The object that is being observed.
  private weak var object: AnyObject?

  /// The key path string to observe.
  private let keyPath: String

  /// The update handler.
  private var handler: KVOObserverHandler

  /// The observation state.
  private enum ObservationState {
    case observing
    case paused
    case stopped
  }

  /// The observation state.
  private var state: ObservationState

  /// Creates a `KVOObserver`.
  ///
  /// - Parameters:
  ///   - object: The object to observe.
  ///   - keyPath: The key path string to observe.
  ///   - handler: The update handler. This callback is called when the value is changed. Passing in the object, old value and new value.
  public init(object: Object, keyPath: String, handler: @escaping KVOObserverHandler) {
    self.object = object
    self.keyPath = keyPath
    self.handler = handler

    self.state = .observing

    super.init()

    (object as AnyObject).addObserver(self, forKeyPath: keyPath, options: [.old, .new], context: &observationContext)
  }

  deinit {
    stopIfNeeded()
  }

  /// Pauses the KVO observation.
  public func pause() {
    switch state {
    case .observing:
      state = .paused
    case .paused:
      return
    case .stopped:
      ChouTi.assertFailure("You cannot pause a KVO observer that has been stopped.", metadata: [
        "object": String(describing: object),
        "keyPath": keyPath,
      ])
    }
  }

  /// Resumes the KVO observation.
  public func resume() {
    switch state {
    case .observing:
      return
    case .paused:
      state = .observing
    case .stopped:
      ChouTi.assertFailure("You cannot resume a KVO observer that has been stopped.", metadata: [
        "object": String(describing: object),
        "keyPath": keyPath,
      ])
    }
  }

  /// Stops the KVO observation.
  public func stop() {
    switch state {
    case .observing,
         .paused:
      state = .stopped
    case .stopped:
      ChouTi.assertFailure("KVO observation has stopped.", metadata: [
        "object": String(describing: object),
        "keyPath": keyPath,
      ])
      return
    }

    guard let object else {
      return
    }
    object.removeObserver(self, forKeyPath: keyPath, context: &observationContext)
  }

  private func stopIfNeeded() {
    switch state {
    case .observing,
         .paused:
      stop()
    case .stopped:
      return
    }
  }

  // swiftlint:disable:next block_based_kvo
  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard state == .observing else {
      return
    }

    guard context == &observationContext else {
      ChouTi.assertFailure("KVOObserver: incorrect context", metadata: [
        "object": String(describing: object),
        "keyPath": "\(keyPath ??? "nil")",
        "observerType": "\(type(of: self))",
      ])
      return
    }

    guard let object = object as? Object else {
      ChouTi.assertFailure("KVOObserver: incorrect object type", metadata: [
        "object": String(describing: object),
        "keyPath": "\(keyPath ??? "nil")",
        "observerType": "\(type(of: self))",
      ])
      return
    }

    guard let oldValue = change?[NSKeyValueChangeKey.oldKey] as? T, let newValue = change?[NSKeyValueChangeKey.newKey] as? T else {
      ChouTi.assertFailure("KVOObserver: failed to get changed values", metadata: [
        "object": "\(object)",
        "keyPath": "\(keyPath ??? "nil")",
        "observerType": "\(type(of: self))",
        "change": String(describing: change),
      ])
      return
    }

    handler(object, oldValue, newValue)
  }
}

/**
 Read more:
 https://fpotter.org/posts/when-is-kvo-unregistration-automatic
 */

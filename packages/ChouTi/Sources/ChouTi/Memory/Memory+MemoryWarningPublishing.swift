//
//  Memory+MemoryWarningPublishing.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/18/21.
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

import Combine

// MARK: - UIKit

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension Memory: MemoryWarningPublishing {

  public static let memoryWarningPublisher: AnyPublisher<Void, Never> = Foundation.NotificationCenter.default
    .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
    .map { _ in () }
    .eraseToAnyPublisher()
}

#elseif os(macOS)

// MARK: - Mac

import AppKit

extension Memory: MemoryWarningPublishing {

  /// To trigger a memory warning on Mac:
  /// - `sudo memory_pressure -S -l warning`
  /// - `sudo memory_pressure -S -l critical`
  ///
  /// https://stackoverflow.com/questions/54531898/how-do-you-simulate-low-memory-conditions-under-macos

  private static let _didReceiveMemoryWarningPublisher = PassthroughSubject<Void, Never>()
  private static var _memoryWarningMonitor: MemoryPressureMonitor?

  public static var memoryWarningPublisher: AnyPublisher<Void, Never> {
    if _memoryWarningMonitor == nil {
      _memoryWarningMonitor = MemoryPressureMonitor(warningHandler: { [weak _didReceiveMemoryWarningPublisher] in
        _didReceiveMemoryWarningPublisher?.send()
      })
    }
    return _didReceiveMemoryWarningPublisher.eraseToAnyPublisher()
  }

  #if DEBUG
  /// Test namespace for accessing internal components.
  static var test: Test { Test() }

  struct Test {
    fileprivate init() {
      ChouTi.assert(Thread.isRunningXCTest, "Test namespace should only be used in test target.")
    }

    var monitor: MemoryPressureMonitor? {
      Memory._memoryWarningMonitor
    }
  }
  #endif
}

final class MemoryPressureMonitor {

  // Reference: https://pushpsenairekar.medium.com/respond-to-low-memory-warnings-using-4-different-ways-bb3da998735a

  private let dispatchSource = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
  private let warningHandler: BlockVoid?

  init(warningHandler: BlockVoid?) {
    self.warningHandler = warningHandler
    dispatchSource.setEventHandler { [weak self] in
      guard let self, self.dispatchSource.isCancelled == false else {
        return
      }
      self.handleMemoryPressureEvent(self.dispatchSource.data)
    }
    dispatchSource.activate()
  }

  private func handleMemoryPressureEvent(_ event: DispatchSource.MemoryPressureEvent) {
    switch event {
    case .warning:
      #if DEBUG
      print("⚠️ Low memory warning")
      #endif
      warningHandler?()
    case .critical:
      #if DEBUG
      print("🚨 Critical low memory warning")
      #endif
      warningHandler?()
    default:
      break
    }
  }

  deinit {
    dispatchSource.cancel()
  }

  // MARK: - Testing

  #if DEBUG
  var test: Test { Test(host: self) }

  struct Test {
    private let host: MemoryPressureMonitor

    fileprivate init(host: MemoryPressureMonitor) {
      ChouTi.assert(Thread.isRunningXCTest, "Test namespace should only be used in test target.")
      self.host = host
    }

    func simulateMemoryPressureEvent(_ event: DispatchSource.MemoryPressureEvent) {
      host.handleMemoryPressureEvent(event)
    }
  }
  #endif
}
#endif

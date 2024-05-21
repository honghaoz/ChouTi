//
//  Memory+MemoryWarningPublisher.swift
//
//  Created by Honghao Zhang on 11/18/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Combine

// MARK: - UIKit

#if canImport(UIKit)
import UIKit

public extension Memory {

  /// A publisher that emits when a memory warning is received.
  ///
  /// Example:
  /// ```swift
  /// private var memoryWarningObservationToken: Cancellable?
  ///
  /// self.memoryWarningObservationToken = Memory.memoryWarningPublisher
  ///   .sink(receiveValue: { [weak self] in
  ///     self?.resetCache()
  ///   })
  /// ```
  static let memoryWarningPublisher = Foundation.NotificationCenter.default
    .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
    .map { _ in () }
}

#elseif os(macOS)

// MARK: - Mac

public extension Memory {

  /// To trigger a memory warning on Mac:
  /// - `sudo memory_pressure -S -l warning`
  /// - `sudo memory_pressure -S -l critical`
  ///
  /// https://stackoverflow.com/questions/54531898/how-do-you-simulate-low-memory-conditions-under-macos
  private static let _didReceiveMemoryWarningPublisher = PassthroughSubject<Void, Never>()
  private static var _memoryWarningMonitor: MemoryPressureMonitor?

  /// A publisher that emits when a memory warning is received.
  ///
  /// Example:
  /// ```swift
  /// private var memoryWarningObservationToken: Cancellable?
  ///
  /// self.memoryWarningObservationToken = Memory.memoryWarningPublisher
  ///   .sink(receiveValue: { [weak self] in
  ///     self?.resetCache()
  ///   })
  /// ```
  static var memoryWarningPublisher: PassthroughSubject<Void, Never> {
    if _memoryWarningMonitor == nil {
      _memoryWarningMonitor = MemoryPressureMonitor(warningHandler: { [weak _didReceiveMemoryWarningPublisher] in
        _didReceiveMemoryWarningPublisher?.send()
      })
    }
    return _didReceiveMemoryWarningPublisher
  }

  #if DEBUG
  /// Trigger memory warning manually.
  /// For testing only.
  static func triggerMemoryWarning() {
    _didReceiveMemoryWarningPublisher.send(())
  }
  #endif
}

private final class MemoryPressureMonitor {

  // Reference: https://pushpsenairekar.medium.com/respond-to-low-memory-warnings-using-4-different-ways-bb3da998735a

  private let dispatchSource = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)

  fileprivate init(warningHandler: BlockVoid?) {
    dispatchSource.setEventHandler { [weak self] in
      if let event = self?.dispatchSource.data, self?.dispatchSource.isCancelled == false {
        switch event {
        case .warning:
          #if DEBUG
          print("⚠️ Low memory warning")
          #endif
          warningHandler?()
        case .critical:
          #if DEBUG
          print("⚠️🔥 Critical memory warning")
          #endif
          warningHandler?()
        default:
          break
        }
      }
    }
    dispatchSource.activate()
  }

  deinit {
    dispatchSource.cancel()
  }
}
#endif

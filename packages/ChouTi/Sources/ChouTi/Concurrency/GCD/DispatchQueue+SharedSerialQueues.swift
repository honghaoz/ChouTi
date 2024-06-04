//
//  DispatchQueue+SharedSerialQueues.swift
//
//  Created by Honghao Zhang on 3/12/22.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Provides shared serial queues to use in Apps.
/// App shouldn't create too many serial queues, use the shared serial queue as target queue.
///
/// GCD readings:
/// https://gist.github.com/tclementdev/6af616354912b0347cdf6db159c37057
/// tips on GCD
/// https://tclementdev.com/posts/what_went_wrong_with_the_libdispatch.html
/// Developers do need to think hard about multithreading and need to carefully consider their program design.
///
/// GCD Internals
/// http://newosxbook.com/articles/GCD.html
///
/// WWDC 2017 706 "Modernizing Grand Central Dispatch Usage" discussion:
/// https://developer.apple.com/forums/thread/131099
///
/// An Introduction to Grand Central Dispatch
/// https://www.humancode.us/2014/07/28/intro-to-gcd.html

public extension DispatchQueue {

  private static let userInteractiveQueue = DispatchQueue.make(label: "io.chouti.queue.qos-ui", qos: .userInteractive, target: .global(qos: .userInteractive))
  private static let userInitiatedQueue = DispatchQueue.make(label: "io.chouti.queue.qos-user-initiated", qos: .userInitiated, target: .global(qos: .userInitiated))
  private static let defaultQueue = DispatchQueue.make(label: "io.chouti.queue.qos-default", qos: .default, target: .global(qos: .default))
  private static let utilityQueue = DispatchQueue.make(label: "io.chouti.queue.qos-utility", qos: .utility, target: .global(qos: .utility))
  private static let backgroundQueue = DispatchQueue.make(label: "io.chouti.queue.qos-background", qos: .background, target: .global(qos: .background))

  /// Get a shared serial queue based on the QoS.
  /// - Parameter qos: The quality-of-service class. Default value is `.default`.
  /// - Returns: A shared serial queue.
  static func shared(qos: DispatchQoS = .default) -> DispatchQueue {
    switch qos {
    case .userInteractive:
      return .userInteractiveQueue
    case .userInitiated:
      return .userInitiatedQueue
    case .default:
      return .defaultQueue
    case .utility:
      return .utilityQueue
    case .background:
      ChouTi.assertFailure("qos .background is not recommended, use .utility instead.")

      // Finally, be wary of the `.background` QoS.
      // There are situations where `.background` QoS work stops completely. Last time a checked, this included low power mode on iOS.
      // From: https://developer.apple.com/forums/thread/690376
      //
      // Other discussions:
      // https://twitter.com/icanzilb/status/1001460996375015424?s=20&t=EKcgnnaAAsdr6VMCLlYwDQ
      return .backgroundQueue
    case .unspecified:
      return .defaultQueue
    default:
      return .defaultQueue
    }
  }
}

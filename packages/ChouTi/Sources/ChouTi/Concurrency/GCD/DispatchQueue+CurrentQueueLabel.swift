//
//  DispatchQueue+CurrentQueueLabel.swift
//
//  Created by Honghao Zhang on 3/28/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

#if DEBUG

import Foundation

public extension DispatchQueue {

  /// Get an optional current queue label.
  @inlinable
  @inline(__always)
  static var currentQueueLabelOrNil: String? {
    String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)
  }

  /// Get a non-optional current queue label.
  @inlinable
  @inline(__always)
  static var currentQueueLabel: String {
    currentQueueLabelOrNil ?? "Unknown"
  }
}

// From: https://stackoverflow.com/a/39809760/3164091
// https://forums.swift.org/t/gcd-getting-current-dispatch-queue-name-with-swift-3/3039/3

#endif

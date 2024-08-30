//
//  DispatchQueue+CurrentQueueLabel.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/28/21.
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

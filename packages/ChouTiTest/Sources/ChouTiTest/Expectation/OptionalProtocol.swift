//
//  OptionalProtocol.swift
//
//  Created by Honghao Zhang on 5/26/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

// Protocol to get the description of the wrapped value inside an optional.
protocol OptionalProtocol {

  /// The description that does not include "Optional(...)"
  var wrappedValueDescription: String { get }
}

extension Optional: OptionalProtocol {

  var wrappedValueDescription: String {
    switch self {
    case .some(let wrapped):
      return "\(wrapped)"
    case .none:
      return "nil"
    }
  }
}

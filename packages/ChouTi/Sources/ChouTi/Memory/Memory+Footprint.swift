//
//  Memory+Footprint.swift
//
//  Created by Honghao Zhang on 11/18/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

public extension Memory {

  /// Get memory footprint in bytes.
  /// - Returns: Memory footprint in bytes.
  static func memoryFootprint() -> Float? {
    /// Get memory usage info.
    /// - https://stackoverflow.com/a/57315975/3164091
    /// - https://forums.developer.apple.com/thread/105088#357415

    // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
    // complex for the Swift C importer, so we have to define them ourselves.
    let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
    // swiftlint:disable:next force_unwrapping
    let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(MemoryLayout.offset(of: \task_vm_info_data_t.min_address)! / MemoryLayout<integer_t>.size)
    var info = task_vm_info_data_t()
    var count = TASK_VM_INFO_COUNT
    let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
      infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
        task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
      }
    }
    guard kr == KERN_SUCCESS, count >= TASK_VM_INFO_REV1_COUNT else {
      return nil
    }

    let usedBytes = Float(info.phys_footprint)
    return usedBytes
  }

  /// Get formatted memory footprint in MB. Like "64.2509765625 MB"
  /// - Returns: Formatted memory footprint in MB.
  static func formattedMemoryFootprint() -> String {
    guard let memoryFootprint = memoryFootprint() else {
      return "Unknown"
    }
    let usedBytes = UInt64(memoryFootprint)
    let usedMB = Double(usedBytes) / 1024 / 1024
    return "\(usedMB) MB"
  }
}

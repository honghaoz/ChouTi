//
//  MachTimeIdTests.swift
//
//  Created by Honghao Zhang on 5/22/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

import ChouTiTest

import ChouTi

final class MachTimeIdTests: XCTestCase {

  func testMachTimeId_noConflict() {
    for _ in 1 ... 10000 {
      let id1 = MachTimeId.id()
      let id2 = MachTimeId.id()

      if id1 == id2 {
        expect(id1) != id2
        break
      }
    }
  }

  func testMachTimeId_noConflict_multiThread() {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "testMachTimeId_noConflict_multiThread", attributes: .concurrent)

    for _ in 1 ... 10000 {
      group.enter()
      queue.async {
        let id1 = MachTimeId.id()
        let id2 = MachTimeId.id()

        if id1 == id2 {
          expect(id1) != id2
        }

        group.leave()
      }
    }

    group.wait()
  }

  func testMachTimeId_noConflict_multiThread2() {
    // use GCD concurrentPerform
    let count = 10000
    var ids = [MachTimeId](repeating: 0, count: count)
    DispatchQueue.concurrentPerform(iterations: count) { i in
      ids[i] = MachTimeId.id()
    }

    // check conflict
    let set = Set(ids)
    expect(set.count) == count
  }

  func testMachTimeIdString_noConflict() {
    for _ in 1 ... 10000 {
      let id1 = MachTimeId.idString()
      let id2 = MachTimeId.idString()

      if id1 == id2 {
        expect(id1) != id2
        break
      }
    }
  }

  func testMachTimeIdString_noConflict_multiThread() {
    let group = DispatchGroup()
    let queue = DispatchQueue(label: "testMachTimeIdString_noConflict_multiThread", attributes: .concurrent)

    for _ in 1 ... 10000 {
      group.enter()
      queue.async {
        let id1 = MachTimeId.idString()
        let id2 = MachTimeId.idString()

        if id1 == id2 {
          expect(id1) != id2
        }

        group.leave()
      }
    }

    group.wait()
  }

  func testMachTimeIdString_noConflict_multiThread2() {
    // use GCD concurrentPerform
    let count = 10000
    var ids = [String](repeating: "", count: count)
    DispatchQueue.concurrentPerform(iterations: count) { i in
      ids[i] = String.machTimeId()
    }

    // check conflict
    let set = Set(ids)
    expect(set.count) == count
  }

  // func test_performance() {
  func performance() {
    PerformanceMeasurer.measure(tag: "mach_absolute_time()", repeatCount: Int(1e6)) {
      _ = mach_absolute_time()
    }

    PerformanceMeasurer.measure(tag: "MachTimeId.id()", repeatCount: Int(1e6)) {
      _ = MachTimeId.id()
    }

    PerformanceMeasurer.measure(tag: "UUID()", repeatCount: Int(1e6)) {
      _ = UUID()
    }

    PerformanceMeasurer.measure(tag: "UUID().uuidString", repeatCount: Int(1e6)) {
      _ = UUID().uuidString
    }

    // [mach_absolute_time()] Elapsed time: 0.23118008332676254
    // [MachTimeId.id()] Elapsed time: 0.2687903333280701
    // [UUID()] Elapsed time: 0.44729162499425
    // [UUID().uuidString] Elapsed time: 0.527294500003336
  }
}

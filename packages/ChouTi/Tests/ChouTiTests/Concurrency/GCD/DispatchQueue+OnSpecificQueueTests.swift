//
//  DispatchQueue+OnSpecificQueueTests.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest
import XCTest

import ChouTi

final class DispatchQueue_OnSpecificQueueTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "test-queue", autoreleaseFrequency: .workItem, target: .shared())

  func testRunOnQueue() {
    queue.sync {
      var hasRun = false
      DispatchQueue.onQueueAsync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        hasRun = true
      }
      XCTAssertTrue(hasRun)
    }
  }

  func testRunOnBackground() {
    var hasRun = false
    DispatchQueue.shared().async {
      DispatchQueue.onQueueAsync(queue: self.queue) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        hasRun = true
      }
      XCTAssertFalse(hasRun)
    }
    XCTAssertFalse(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnQueueWithDelay() {
    var hasRun = false
    DispatchQueue.onQueueAsync(queue: queue, delay: 0) {
      dispatchPrecondition(condition: .onQueue(self.queue))
      hasRun = true
    }
    XCTAssertFalse(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnQueueSync() {
    queue.sync {
      var hasRun = false
      DispatchQueue.onQueueSync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        hasRun = true
      }
      XCTAssertTrue(hasRun)
    }
  }

//  func testMakeSerialQueue() {
//    helperDispatchQueueReleaseObject()
//    wait(timeout: 4)
//    print("➡️ end")
//  }
//
//  /// Test difference between autoreleaseFrequency
//  /// Seems like no difference.
//  private func helperDispatchQueueReleaseObject() {
//
//    class Foo: NSObject {
//      let id: String
//      let initTime: UInt64
//
//      public init(id: String) {
//        self.id = id
//        initTime = mach_absolute_time()
//      }
//
//      func dummy() {}
//
//      deinit {
//        print("➡️ \(id): \(machTimeInterval(from: initTime, to: mach_absolute_time()))")
//      }
//    }
//
//    let foo1 = Foo(id: "workItem")
//    let queue1 = DispatchQueue.make(label: "autoreleaseFrequency.workItem", autoreleaseFrequency: .workItem, target: .shared())
//    queue1.asyncAfter(deadline: .now() + 1) {
//      foo1.dummy()
//    }
//
//    let foo2 = Foo(id: "never")
//    let queue2 = DispatchQueue.make(label: "autoreleaseFrequency.never", autoreleaseFrequency: .never, target: .shared())
//    queue2.asyncAfter(deadline: .now() + 1) {
//      foo2.dummy()
//    }
//
//    let foo3 = Foo(id: "inherit")
//    let queue3 = DispatchQueue.make(label: "autoreleaseFrequency.inherit", autoreleaseFrequency: .inherit, target: .shared())
//    queue3.asyncAfter(deadline: .now() + 1) {
//      foo3.dummy()
//    }
//  }
}

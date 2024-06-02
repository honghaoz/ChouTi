//
//  DispatchQueue+OnSpecificQueueTests.swift
//
//  Created by Honghao Zhang on 1/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

final class DispatchQueue_OnSpecificQueueTests: XCTestCase {

  private let queue = DispatchQueue.make(label: "test-queue", autoreleaseFrequency: .workItem, target: .shared())

  func test_isOnQueue_nonMakeQueue() {
    let queue = DispatchQueue(label: "test-queue-non-make-queue")
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "Expect a queue label for queue: \"test-queue-non-make-queue\", use static make(...) method to create a queue."
    }
    queue.sync {
      expect(DispatchQueue.isOnQueue(queue)) == false
    }
    Assert.resetTestAssertionFailureHandler()
  }

  func test_isOnQueue_nonMakeQueue_commonQueue() {
    let queue = DispatchQueue.global()
    queue.sync {
      expect(DispatchQueue.isOnQueue(queue)) == true
    }
  }

  func testRunOnQueue() {
    queue.sync {
      var hasRun = false
      DispatchQueue.onQueueAsync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        hasRun = true
      }
      expect(hasRun) == true // should run immediately
    }
  }

  func testRunOnBackground() {
    var hasRun = false
    var logs: [String] = []
    logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] before async on shared queue")
    DispatchQueue.shared().async {
      logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] before async on self queue")
      DispatchQueue.onQueueAsync(queue: self.queue) {
        logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] on self queue")
        dispatchPrecondition(condition: .onQueue(self.queue))
        hasRun = true
        logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] on self queue executed")
      }
      logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] after async on self queue")
      expect(hasRun) == false
    }
    logs.append("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] after async on shared queue")
    expect(hasRun, "logs: \(logs)") == false
    expect(hasRun).toEventually(beTrue())

    // var hasRun = false
    // print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] before async on shared queue")
    // DispatchQueue.shared().async {
    //   print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] before async on self queue")
    //   DispatchQueue.onQueueAsync(queue: self.queue) {
    //     print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] on self queue")
    //     dispatchPrecondition(condition: .onQueue(self.queue))
    //     hasRun = true
    //     print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] on self queue executed")
    //   }
    //   print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] after async on self queue")
    //   XCTAssertFalse(hasRun)
    // }
    // print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] after async on shared queue")
    // XCTAssertFalse(hasRun)
    // print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] before wait")
    // wait(timeout: 0.1)
    // print("DEBUG[\(#function)][\(Thread.current)][\(DispatchQueue.currentQueueLabel)] after wait")
    // XCTAssertTrue(hasRun)

    // Local output:
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600001710000>{number = 1, name = main}][com.apple.main-thread] before async on shared queue
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600001710000>{number = 1, name = main}][com.apple.main-thread] after async on shared queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x60000174ac00>{number = 2, name = (null)}][io.chouti.queue.qos-default] before async on self queue
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600001710000>{number = 1, name = main}][com.apple.main-thread] before wait
    // DEBUG[testRunOnBackground()][<NSThread: 0x60000174ac00>{number = 2, name = (null)}][io.chouti.queue.qos-default] after async on self queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x60000174ac00>{number = 2, name = (null)}][test-queue] on self queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x60000174ac00>{number = 2, name = (null)}][test-queue] on self queue executed
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600001710000>{number = 1, name = main}][com.apple.main-thread] after wait

    // CI output:
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600003f2c080>{number = 1, name = main}][com.apple.main-thread] before async on shared queue
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600003f2c080>{number = 1, name = main}][com.apple.main-thread] after async on shared queue
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600003f2c080>{number = 1, name = main}][com.apple.main-thread] before wait
    // DEBUG[testRunOnBackground()][<NSThread: 0x600003f66e00>{number = 2, name = (null)}][io.chouti.queue.qos-default] before async on self queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x600003f66e00>{number = 2, name = (null)}][io.chouti.queue.qos-default] after async on self queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x600003f66e00>{number = 2, name = (null)}][test-queue] on self queue
    // DEBUG[testRunOnBackground()][<NSThread: 0x600003f66e00>{number = 2, name = (null)}][test-queue] on self queue executed
    // DEBUG[testRunOnBackground()][<_NSMainThread: 0x600003f2c080>{number = 1, name = main}][com.apple.main-thread] after wait
  }

  func testRunOnQueueWithDelay() {
    var hasRun = false
    DispatchQueue.onQueueAsync(queue: queue, delay: 0) {
      dispatchPrecondition(condition: .onQueue(self.queue))
      hasRun = true
    }
    expect(hasRun).toEventually(beTrue())
  }

  func test_makeQueue() {
    let queue = DispatchQueue.make(label: "test-queue")
    expect(queue.label) == "test-queue"
    expect(queue.qos) == .unspecified
  }

  func test_makeMainQueue() {
    let queue = DispatchQueue.makeMain()
    expect(queue) === .main
  }

  func test_isOnCooperativeQueue() {
    let expectation = XCTestExpectation(description: "isOnCooperativeQueue")

    @Sendable func someAsyncFunction() async {
      expect(DispatchQueue.isOnCooperativeQueue()) == true
      expectation.fulfill()
    }

    Task {
      await someAsyncFunction()
    }
    expect(DispatchQueue.isOnCooperativeQueue()) == false

    wait(for: [expectation], timeout: 1)
  }

  func test_onQueueAsync_block() {
    // positive delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync block")
      DispatchQueue.onQueueAsync(queue: queue, delay: 0.1) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 1)
    }

    // non negative delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync block")
      DispatchQueue.onQueueAsync(queue: queue, delay: 0) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 1)
    }

    // no delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync block")
      DispatchQueue.onQueueAsync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 1)
    }

    // positive delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync block")
      onQueueAsync(queue: queue, delay: 0.1) {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      wait(for: [expectation], timeout: 1)
    }
  }

  func test_onQueueSync_block() {
    var value = 0
    DispatchQueue.onQueueSync(queue: queue) {
      dispatchPrecondition(condition: .onQueue(self.queue))
      value = 1
    }
    expect(value) == 1
  }

  func test_onQueueAsync_workItem() {
    // positive delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync workItem")
      let workItem = DispatchWorkItem {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      DispatchQueue.onQueueAsync(queue: queue, delay: 0.1, execute: workItem)
      wait(for: [expectation], timeout: 1)
    }

    // non negative delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync workItem")
      let workItem = DispatchWorkItem {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      DispatchQueue.onQueueAsync(queue: queue, delay: 0, execute: workItem)
      wait(for: [expectation], timeout: 1)
    }

    // no delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync workItem")
      let workItem = DispatchWorkItem {
        dispatchPrecondition(condition: .onQueue(.main))
        expectation.fulfill()
      }
      DispatchQueue.onQueueAsync(queue: .main, execute: workItem)
      wait(for: [expectation], timeout: 1)
    }

    // positive delay
    do {
      let expectation = XCTestExpectation(description: "onQueueAsync workItem")
      let workItem = DispatchWorkItem {
        dispatchPrecondition(condition: .onQueue(self.queue))
        expectation.fulfill()
      }
      onQueueAsync(queue: queue, delay: 0.1, execute: workItem)
      wait(for: [expectation], timeout: 1)
    }
  }

  func test_asyncIfNeeded() {
    // main
    do {
      var value = 0
      DispatchQueue.main.asyncIfNeeded {
        expect(DispatchQueue.isOnQueue(.main)) == true
        value = 1
      }
      expect(value) == 1
    }

    // background
    do {
      let expectation = XCTestExpectation(description: "asyncIfNeeded")
      var value = 0
      queue.asyncIfNeeded {
        expect(DispatchQueue.isOnQueue(self.queue)) == true
        value = 1
        expectation.fulfill()
      }
      expect(value) == 0
      wait(for: [expectation], timeout: 1)
    }
  }

  func test_syncIfNeeded() {
    // main
    do {
      var value = 0
      DispatchQueue.main.syncIfNeeded {
        expect(DispatchQueue.isOnQueue(.main)) == true
        value = 1
      }
      expect(value) == 1
    }

    // background
    do {
      var value = 0
      queue.syncIfNeeded {
        expect(DispatchQueue.isOnQueue(queue)) == true
        value = 1
      }
      expect(value) == 1
    }
  }

  func testRunOnQueueSync() {
    do {
      var hasRun = false
      DispatchQueue.onQueueSync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(queue))
        hasRun = true
      }
      expect(hasRun) == true
    }
    do {
      var hasRun = false
      onQueueSync(queue: queue) {
        dispatchPrecondition(condition: .onQueue(queue))
        hasRun = true
      }
      expect(hasRun) == true
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

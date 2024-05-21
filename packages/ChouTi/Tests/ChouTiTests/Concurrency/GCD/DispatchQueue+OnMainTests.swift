//
//  DispatchQueue+OnMainTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
@testable import ChouTi

// TODO: restore tests

// import Nimble
// import Quick

// class DispatchQueue_OnMainTests: QuickSpec {
//
//  override func spec() {
//    describe("dispatch queue on main") {
//      context("if dispatch from the main queue") {
//        it("should run async method immediately") {
//          var hasRun = false
//          DispatchQueue.onMainAsync {
//            hasRun = true
//          }
//          expect(hasRun).to(beTrue())
//        }
//
//        it("should run sync method immediately") {
//          var hasRun = false
//          DispatchQueue.onMainSync {
//            hasRun = true
//          }
//          expect(hasRun).to(beTrue())
//        }
//      }
//
//      context("if dispatch from another queue") {
//        it("should run async method later") {
//          var hasRun = false
//          DispatchQueue.shared(qos: .userInitiated).async {
//            DispatchQueue.onMainAsync {
//              hasRun = true
//            }
//            expect(hasRun).to(beFalse())
//          }
//          expect(hasRun).toEventually(beTrue())
//        }
//
//        it("should still run sync method immediately") {
//          var hasRun = false
//          DispatchQueue.make(label: "dummy dispatch queue", target: .shared()).async {
//            DispatchQueue.onMainSync {
//              hasRun = true
//            }
//            expect(hasRun).to(beTrue())
//          }
//        }
//      }
//    }
//  }
// }

import XCTest

final class DispatchQueue_OnMainAsyncTests: XCTestCase {

  func testRunOnMain() {
    var hasRun = false
    DispatchQueue.onMainAsync {
      XCTAssertTrue(Thread.isMainThread)
      hasRun = true
    }
    XCTAssertTrue(hasRun)
  }

  func testRunOnBackground() {
    var hasRun = false
    DispatchQueue.global().async {
      XCTAssertFalse(Thread.isMainThread)
      DispatchQueue.onMainAsync {
        XCTAssertTrue(Thread.isMainThread)
        hasRun = true
      }
      XCTAssertFalse(hasRun)
    }
    XCTAssertFalse(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnMainWithPositiveDelay() {
    var hasRun = false
    // if delay is 0, it dispatches to next run loop
    DispatchQueue.onMainAsync(delay: 0.01) {
      XCTAssertTrue(Thread.isMainThread)
      hasRun = true
    }
    XCTAssertFalse(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnMainWithZeroDelay() {
    var hasRun = false
    // delay is zero, dispatches directly
    DispatchQueue.onMainAsync(delay: 0) {
      XCTAssertTrue(Thread.isMainThread)
      hasRun = true
    }
    XCTAssertTrue(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnMainWithNegativeDelay() {
    var hasRun = false
    // delay is negative, dispatches directly
    DispatchQueue.onMainAsync(delay: -1) {
      XCTAssertTrue(Thread.isMainThread)
      hasRun = true
    }
    XCTAssertTrue(hasRun)
    wait(timeout: 0.05)
    XCTAssertTrue(hasRun)
  }

  func testRunOnMainSync() {
    var hasRun = false
    DispatchQueue.onMainSync {
      XCTAssertTrue(Thread.isMainThread)
      hasRun = true
    }
    XCTAssertTrue(hasRun)
  }
}

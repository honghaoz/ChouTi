//
//  DispatchQueue+OnMainAsyncTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

import ChouTi

final class DispatchQueue_OnMainAsyncTests: XCTestCase {

  func testRunOnMain() {
    var hasRun = false
    DispatchQueue.onMainAsync {
      expect(Thread.isMainThread) == true
      hasRun = true
    }
    expect(hasRun) == true
  }

  func testRunOnBackground() {
    var hasRun = false
    DispatchQueue.global().async {
      expect(Thread.isMainThread) == false
      DispatchQueue.onMainAsync {
        expect(Thread.isMainThread) == true
        hasRun = true
      }
      expect(hasRun) == false
    }
    expect(hasRun).toEventually(beTrue())
  }

  func testRunOnMainWithPositiveDelay() {
    var hasRun = false
    // if delay is 0, it dispatches to next run loop
    DispatchQueue.onMainAsync(delay: 0.01) {
      expect(Thread.isMainThread) == true
      hasRun = true
    }
    expect(hasRun) == false
    expect(hasRun).toEventually(beTrue())
  }

  func testRunOnMainWithZeroDelay() {
    var hasRun = false
    // delay is zero, dispatches directly
    DispatchQueue.onMainAsync(delay: 0) {
      expect(Thread.isMainThread) == true
      hasRun = true
    }
    expect(hasRun) == true
  }

  func testRunOnMainWithNegativeDelay() {
    var hasRun = false
    // delay is negative, dispatches directly
    DispatchQueue.onMainAsync(delay: -1) {
      expect(Thread.isMainThread) == true
      hasRun = true
    }
    expect(hasRun) == true
  }

  func testRunOnMainSync() {
    var hasRun = false
    DispatchQueue.onMainSync {
      expect(Thread.isMainThread) == true
      hasRun = true
    }
    expect(hasRun) == true
  }
}

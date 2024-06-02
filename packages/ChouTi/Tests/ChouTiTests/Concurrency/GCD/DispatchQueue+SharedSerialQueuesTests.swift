//
//  DispatchQueue+SharedSerialQueuesTests.swift
//
//  Created by Honghao Zhang on 6/1/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

final class DispatchQueue_SharedSerialQueuesTests: XCTestCase {

  func test_shared() {
    let userInteractiveQueue = DispatchQueue.shared(qos: .userInteractive)
    expect(userInteractiveQueue.label) == "io.chouti.queue.qos-ui"
    expect(userInteractiveQueue.qos) == .userInteractive

    let userInitiatedQueue = DispatchQueue.shared(qos: .userInitiated)
    expect(userInitiatedQueue.label) == "io.chouti.queue.qos-user-initiated"
    expect(userInitiatedQueue.qos) == .userInitiated

    let defaultQueue = DispatchQueue.shared(qos: .default)
    expect(defaultQueue.label) == "io.chouti.queue.qos-default"
    expect(defaultQueue.qos) == .default

    let utilityQueue = DispatchQueue.shared(qos: .utility)
    expect(utilityQueue.label) == "io.chouti.queue.qos-utility"
    expect(utilityQueue.qos) == .utility

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "qos .background is not recommended, use .utility instead."
    }
    let backgroundQueue = DispatchQueue.shared(qos: .background)
    expect(backgroundQueue.label) == "io.chouti.queue.qos-background"
    expect(backgroundQueue.qos) == .background
    Assert.resetTestAssertionFailureHandler()

    let unspecifiedQueue = DispatchQueue.shared(qos: .unspecified)
    expect(unspecifiedQueue.label) == "io.chouti.queue.qos-default"
    expect(unspecifiedQueue.qos) == .default

    let customQueue = DispatchQueue.shared(qos: DispatchQoS(qosClass: .default, relativePriority: 10))
    expect(customQueue.label) == "io.chouti.queue.qos-default"
    expect(customQueue.qos) == .default
  }

  func test_makeSerialQueue() {
    do {
      let serialQueue = DispatchQueue.makeSerialQueue(label: "test")
      expect(serialQueue.label) == "io.chouti.serial-queue.test"
      expect(serialQueue.qos) == .default
    }

    // set qos
    do {
      let serialQueue = DispatchQueue.makeSerialQueue(label: "test", qos: .userInteractive)
      expect(serialQueue.label) == "io.chouti.serial-queue.test"
      expect(serialQueue.qos) == .userInteractive
    }
  }
}

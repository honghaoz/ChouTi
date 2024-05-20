//
//  MachTimeIdTests.swift
//
//  Created by Honghao Zhang on 5/22/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation
import XCTest
import ChouTiTest

import ChouTi

final class MachTimeIdTests: XCTestCase {

  func testMachTimeId_canConflict() {
    var isConflicted: Bool = false
    for _ in 1 ... 100 {
      let id1 = MachTimeId.id()
      let id2 = MachTimeId.id()

      if id1 == id2 {
        isConflicted = true
        break
      }
    }

    expect(isConflicted) == true // it's totally possible to have conflicts for consecutive calls
  }

  func testMachTimeId_noConflict() {
    let id1 = MachTimeId.id()
    let a = UUID().uuidString
    _ = a
    let id2 = MachTimeId.id()
    expect(id1) != id2
  }

  func testMachTimeIdString_noConflict() {
    let id1 = MachTimeId.idString()
    let a = UUID().uuidString
    _ = a
    let id2 = MachTimeId.idString()
    expect(id1) != id2
  }

  func testStringMachTimeId() {
    let id1 = String.machTimeId()
    let a = UUID().uuidString
    _ = a
    let id2 = String.machTimeId()
    expect(id1) != id2
  }
}

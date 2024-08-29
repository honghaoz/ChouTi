//
//  SystemTests.swift
//
//  Created by Honghao Zhang on 8/28/24.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

import ChouTi
import ChouTiTest

class SystemTests: XCTestCase {

  #if os(macOS)
  func testSystem() {
    expect(System.macOS_sonoma) == true
    expect(System.macOS_ventura) == true
    expect(System.macOS_monterey) == true
    expect(System.macOS_bigSur) == true
  }
  #endif

  #if os(iOS)
  func testSystem() {
    expect(System.iOS_17) == true
    expect(System.iOS_16) == true
    expect(System.iOS_15) == true
    expect(System.iOS_14) == true
    expect(System.iOS_13) == true
  }
  #endif
}

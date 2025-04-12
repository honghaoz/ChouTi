//
//  MeasureTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 4/12/25.
//  Copyright © 2020 Honghao Zhang.
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang (github.com/honghaoz)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import XCTest
import ChouTiTest

class MeasureTests: XCTestCase {

  func test_measure() {
    let objectAllocationTime = ChouTiTest.measure(repeat: 100) {
      _ = NSObject()
    }
    let layerAllocationTime = ChouTiTest.measure(repeat: 100) {
      _ = CALayer()
    }
    print("object allocation time: \(objectAllocationTime)")
    print("layer allocation time: \(layerAllocationTime)")
    expect(layerAllocationTime) > objectAllocationTime
  }

  func test_measure_throws() throws {
    func makeObject() throws -> NSObject {
      return NSObject()
    }
    func makeLayer() throws -> CALayer {
      return CALayer()
    }

    let objectAllocationTime = try ChouTiTest.measure(repeat: 100) {
      _ = try makeObject()
    }
    let layerAllocationTime = try ChouTiTest.measure(repeat: 100) {
      _ = try makeLayer()
    }
    print("object allocation time: \(objectAllocationTime)")
    print("layer allocation time: \(layerAllocationTime)")
    expect(layerAllocationTime) > objectAllocationTime
  }

  func test_measure_async() async throws {
    func makeObject() async throws -> NSObject {
      return NSObject()
    }
    func makeLayer() async throws -> CALayer {
      return CALayer()
    }

    let objectAllocationTime = try await ChouTiTest.measure(repeat: 100) {
      _ = try await makeObject()
    }
    let layerAllocationTime = try await ChouTiTest.measure(repeat: 100) {
      _ = try await makeLayer()
    }
    print("object allocation time: \(objectAllocationTime)")
    print("layer allocation time: \(layerAllocationTime)")
    expect(layerAllocationTime) > objectAllocationTime
  }
}

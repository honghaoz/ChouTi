//
//  CGAffineTransform+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 3/11/22.
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

import ChouTiTest

import ChouTi

class CGAffineTransform_Extensions: XCTestCase {

  // MARK: - Conversion

  #if os(macOS)
  func test_affineTransform() {
    expect(CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 10, ty: 20).affineTransform) == AffineTransform(m11: 1, m12: 2, m21: 3, m22: 4, tX: 10, tY: 20)
  }
  #endif

  // MARK: - Static

  func test_zero() {
    expect(CGAffineTransform.zero) == CGAffineTransform(a: 0, b: 0, c: 0, d: 0, tx: 0, ty: 0)
  }

  func test_identity() {
    expect(CGAffineTransform.identity) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
  }

  func test_horizontalFlip() {
    expect(CGAffineTransform.horizontalFlip) == CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
  }

  func test_verticalFlip() {
    expect(CGAffineTransform.verticalFlip) == CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
  }

  func test_diagonalFlip() {
    expect(CGAffineTransform.diagonalFlip) == CGAffineTransform(a: -1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
  }

  // MARK: - Factory

  // MARK: - Translation

  func test_factory_translation() {
    expect(CGAffineTransform.translation(x: 10, y: 20)) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 10, ty: 20)
    expect(CGAffineTransform.translation(10, 20)) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 10, ty: 20)
  }

  // MARK: - Scale

  func test_factory_scale() {
    expect(CGAffineTransform.scale(x: 10, y: 10)) == CGAffineTransform(a: 10, b: 0, c: 0, d: 10, tx: 0, ty: 0)
    expect(CGAffineTransform.scale(10, 10)) == CGAffineTransform(a: 10, b: 0, c: 0, d: 10, tx: 0, ty: 0)
  }

  func test_get_scale() {
    expect(CGAffineTransform.scale(x: 10, y: 10).scale) == 10
  }

  // MARK: - Rotation

  func test_factory_rotation() {
    expect(CGAffineTransform.rotation(angle: .degrees(45))) == CGAffineTransform(a: 0.7071067811865476, b: 0.7071067811865475, c: -0.7071067811865475, d: 0.7071067811865476, tx: 0, ty: 0)
  }

  // MARK: - Shear

  func test_factory_shear() {
    expect(CGAffineTransform.shear(x: 10, y: 20)) == CGAffineTransform(a: 1, b: 20, c: 10, d: 1, tx: 0, ty: 0)
    expect(CGAffineTransform.shear(10, 20)) == CGAffineTransform(a: 1, b: 20, c: 10, d: 1, tx: 0, ty: 0)
  }

  // MARK: - Initializer

  func test_init_rotationAngle() {
    expect(CGAffineTransform(rotationAngle: .degrees(45))) == CGAffineTransform(a: 0.7071067811865476, b: 0.7071067811865475, c: -0.7071067811865475, d: 0.7071067811865476, tx: 0, ty: 0)
  }

  // MARK: - Operations

  // MARK: - Invert

  func test_invert() {
    expect(CGAffineTransform.scale(x: 10, y: 10).invert()) == CGAffineTransform.scale(x: 0.1, y: 0.1)
  }

  // MARK: - Translate

  func test_translate() {
    expect(CGAffineTransform.translation(x: 10, y: 20).translate(x: 30, y: 40)) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 40, ty: 60)
    expect(CGAffineTransform.translation(10, 20).translate(30, 40)) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 40, ty: 60)
  }

  // MARK: - Scale

  func test_scale() {
    expect(CGAffineTransform.scale(x: 10, y: 10).scale(x: 30, y: 40)) == CGAffineTransform.scale(x: 300, y: 400)
    expect(CGAffineTransform.scale(10, 20).scale(30, 40)) == CGAffineTransform.scale(x: 300, y: 800)
  }

  // MARK: - Rotate

  func test_rotate() {
    expect(
      CGAffineTransform.rotation(angle: .degrees(45)).rotate(angle: .degrees(45)).isApproximatelyEqual(to: CGAffineTransform.rotation(angle: .degrees(90)), absoluteTolerance: 0.000001)
    ) == true
  }

  // MARK: - Shear

  func test_shear() {
    expect(CGAffineTransform.translation(x: 5, y: 10).shear(x: 1, y: 0.5)) == CGAffineTransform(a: 1.0, b: 0.5, c: 1.0, d: 1.0, tx: 15.0, ty: 12.5)
    expect(CGAffineTransform.translation(5, 10).shear(1, 0.5)) == CGAffineTransform(a: 1.0, b: 0.5, c: 1.0, d: 1.0, tx: 15.0, ty: 12.5)
    expect(CGAffineTransform.scale(10, 10).shear(30, 40)) == CGAffineTransform(a: 10.0, b: 400.0, c: 300.0, d: 10.0, tx: 0.0, ty: 0.0)
  }

  // MARK: - Hashable

  func test_hash() {
    expect(CGAffineTransform.translation(x: 10, y: 20).hashValue) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 10, ty: 20).hashValue
  }

  // MARK: - Concat

  func test_concat() {
    expect(CGAffineTransform.translation(x: 10, y: 20).concat(CGAffineTransform.translation(x: 30, y: 40))) == CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 40, ty: 60)
  }

  // MARK: - isApproximatelyEqual

  func test_isApproximatelyEqual() {
    expect(CGAffineTransform.scale(x: 10.001, y: 10).isApproximatelyEqual(to: CGAffineTransform.scale(x: 10, y: 10), absoluteTolerance: 0.01)) == true
    expect(CGAffineTransform.scale(x: 10, y: 10).isApproximatelyEqual(to: CGAffineTransform.scale(x: 11, y: 11), absoluteTolerance: 1.1)) == true
  }

  // MARK: - Concatenation

  func test_concatenated() {
    // empty
    expect([CGAffineTransform]().concatenated()) == CGAffineTransform.identity

    // single
    expect([CGAffineTransform.translation(x: 10, y: 20)].concatenated()) == CGAffineTransform.translation(x: 10, y: 20)

    // non-empty
    do {
      let transforms: [CGAffineTransform] = [
        .translation(x: 10, y: 20),
        .translation(x: 30, y: 40),
        .translation(x: 50, y: 60),
        .scale(x: 10, y: 10),
      ]
      let concatenated = transforms.concatenated()
      expect(concatenated) == CGAffineTransform(a: 10.0, b: 0.0, c: 0.0, d: 10.0, tx: 900.0, ty: 1200.0)
    }
  }
}

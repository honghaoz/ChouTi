//
//  CATransform3D+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/2/24.
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

#if canImport(QuartzCore)
import QuartzCore

import ChouTiTest

import ChouTi

class CATransform3D_Extensions: XCTestCase {

  // MARK: - Conversion

  func test_affineTransform() {
    expect(
      CATransform3D(m11: 1, m12: 2, m13: 3, m14: 4, m21: 5, m22: 6, m23: 7, m24: 8, m31: 9, m32: 10, m33: 11, m34: 12, m41: 13, m42: 14, m43: 15, m44: 16).affineTransform
    ) == CGAffineTransform(a: 1, b: 2, c: 5, d: 6, tx: 13, ty: 14)

    expect(
      CATransform3D.scale(x: 10, y: 10, z: 10).affineTransform
    ) == CGAffineTransform.scale(x: 10, y: 10)

    expect(
      CATransform3D.translation(x: 10, y: 10, z: 10).affineTransform
    ) == CGAffineTransform.translation(x: 10, y: 10)

    /// In 3D space, a rotation around the x-axis affects the y and z coordinates, while leaving x unchanged. The transformation matrix looks like this:
    ///    | 1    0        0    |
    ///    | 0   cos(θ)  -sin(θ)|
    ///    | 0   sin(θ)   cos(θ)|
    ///
    /// The affine transform is a 2D transform, so we only use the first two rows and columns.
    /// The projection to 2D plane essentially flattens the z-dimension. Resulting in a transform that
    /// looks like this:
    ///    | 1    0    |
    ///    | 0  cos(θ) |
    ///
    /// - The x-coordinates remain unchanged (hence a = 1, c = 0)
    /// - The y-coordinates are scaled by cos(θ) (hence d = cos(θ))
    /// - There's no shearing or translation (b = 0, tx = 0, ty = 0)
    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0).affineTransform
    ) == CGAffineTransform(a: 1, b: 0, c: 0, d: cos(.degrees(30)), tx: 0, ty: 0)

    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0).affineTransform
    ) == CGAffineTransform(a: cos(.degrees(30)), b: 0, c: 0, d: 1, tx: 0, ty: 0)

    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1).affineTransform
    ) == CGAffineTransform.rotation(angle: .degrees(30))

    expect(
      CATransform3D.identity.affineTransform
    ) == CGAffineTransform.identity

    expect(
      CATransform3D.zero.affineTransform
    ) == CGAffineTransform.zero
  }

  // MARK: - Check

  func test_isIdentity() {
    expect(CATransform3D.identity.isIdentity) == true
    expect(CATransform3D.zero.isIdentity) == false

    expect(CATransform3D.identity) == .identity
  }

  func test_isAffine() {
    expect(CATransform3D.identity.isAffine) == true
    expect(CATransform3D.zero.isAffine) == false

    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0).isAffine
    ) == false

    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0).isAffine
    ) == false

    expect(
      CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1).isAffine
    ) == true
  }

  // MARK: - Static

  func test_identity() {
    expect(CATransform3D.identity) == CATransform3DIdentity
  }

  func test_zero() {
    expect(CATransform3D.zero) == CATransform3D(m11: 0, m12: 0, m13: 0, m14: 0, m21: 0, m22: 0, m23: 0, m24: 0, m31: 0, m32: 0, m33: 0, m34: 0, m41: 0, m42: 0, m43: 0, m44: 0)
  }

  func test_horizontalFlip() {
    expect(CATransform3D.horizontalFlip) == CATransform3D(m11: -1, m12: 0, m13: 0, m14: 0, m21: 0, m22: 1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)
  }

  func test_verticalFlip() {
    expect(CATransform3D.verticalFlip) == CATransform3D(m11: 1, m12: 0, m13: 0, m14: 0, m21: 0, m22: -1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)
  }

  // MARK: - Factory

  // MARK: - Translation

  func test_translation() {
    expect(CATransform3D.translation(x: 10, y: 20, z: 30)) == CATransform3D(m11: 1, m12: 0, m13: 0, m14: 0, m21: 0, m22: 1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 10, m42: 20, m43: 30, m44: 1)
    expect(CATransform3D.translation(10, 20, 30)) == CATransform3D(m11: 1, m12: 0, m13: 0, m14: 0, m21: 0, m22: 1, m23: 0, m24: 0, m31: 0, m32: 0, m33: 1, m34: 0, m41: 10, m42: 20, m43: 30, m44: 1)
  }

  // MARK: - Scale

  func test_scale() {
    expect(CATransform3D.scale(x: 10, y: 20, z: 30)) == CATransform3D(m11: 10, m12: 0, m13: 0, m14: 0, m21: 0, m22: 20, m23: 0, m24: 0, m31: 0, m32: 0, m33: 30, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)
    expect(CATransform3D.scale(10, 20, 30)) == CATransform3D(m11: 10, m12: 0, m13: 0, m14: 0, m21: 0, m22: 20, m23: 0, m24: 0, m31: 0, m32: 0, m33: 30, m34: 0, m41: 0, m42: 0, m43: 0, m44: 1)
  }

  // MARK: - Rotation

  func test_rotation() {
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .x)) == CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0)
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .y)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0)
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .z)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1)
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .x)) == CATransform3D.rotation(.degrees(30), 1, 0, 0)
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .y)) == CATransform3D.rotation(.degrees(30), 0, 1, 0)
    expect(CATransform3D.rotation(angle: .degrees(30), axis: .z)) == CATransform3D.rotation(.degrees(30), 0, 0, 1)

    expect(CATransform3D.rotation(angle: .degrees(30), axis: .z).affineTransform) == CGAffineTransform.rotation(angle: .degrees(30))
  }

  // MARK: - Affine Transform

  func test_makeFromAffineTransform() {
    expect(CATransform3D.affineTransform(CGAffineTransform.identity)) == CATransform3DIdentity
    expect(CATransform3D.affineTransform(CGAffineTransform.zero)) == CATransform3D(m11: 0.0, m12: 0.0, m13: 0.0, m14: 0.0, m21: 0.0, m22: 0.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0)

    expect(
      CATransform3D.affineTransform(CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6))
    ) == CATransform3D(m11: 1.0, m12: 2.0, m13: 0.0, m14: 0.0, m21: 3.0, m22: 4.0, m23: 0.0, m24: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m41: 5.0, m42: 6.0, m43: 0.0, m44: 1.0)

    expect(
      CATransform3D.affineTransform(CGAffineTransform.rotation(angle: .degrees(30)))
    ) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1)
  }

  // MARK: - Operations

  func test_invert() {
    expect(
      CATransform3D(m11: 1, m12: 2, m13: 3, m14: 4, m21: 5, m22: 6, m23: 7, m24: 8, m31: 9, m32: 10, m33: 11, m34: 12, m41: 13, m42: 14, m43: 15, m44: 16).invert()
    ) == CATransform3D(m11: 1, m12: 2, m13: 3, m14: 4, m21: 5, m22: 6, m23: 7, m24: 8, m31: 9, m32: 10, m33: 11, m34: 12, m41: 13, m42: 14, m43: 15, m44: 16)

    expect(
      CATransform3D.scale(x: 10, y: 10, z: 10).invert()
    ) == CATransform3D.scale(x: 1 / 10, y: 1 / 10, z: 1 / 10)

    expect(
      CATransform3D.translation(x: 10, y: 10, z: 10).invert()
    ) == CATransform3D.translation(x: -10, y: -10, z: -10)
  }

  func test_operation_translate() {
    expect(CATransform3D.identity.translate()) == CATransform3D.identity
    expect(CATransform3D.identity.translate(x: 10, y: 20, z: 30)) == CATransform3D.translation(x: 10, y: 20, z: 30)
    expect(CATransform3D.identity.translate(10, 20, 30)) == CATransform3D.translation(x: 10, y: 20, z: 30)
  }

  func test_operation_scale() {
    expect(CATransform3D.identity.scale()) == CATransform3D.identity
    expect(CATransform3D.identity.scale(x: 10, y: 20, z: 30)) == CATransform3D.scale(x: 10, y: 20, z: 30)
    expect(CATransform3D.identity.scale(10, 20, 30)) == CATransform3D.scale(x: 10, y: 20, z: 30)
  }

  func test_operation_rotate() {
    expect(CATransform3D.identity.rotate(angle: .degrees(30), axis: .x)) == CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0)
    expect(CATransform3D.identity.rotate(angle: .degrees(30), axis: .y)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0)
    expect(CATransform3D.identity.rotate(angle: .degrees(30), axis: .z)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1)

    expect(CATransform3D.identity.rotate(angle: .degrees(30), x: 1, y: 0, z: 0)) == CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0)
    expect(CATransform3D.identity.rotate(angle: .degrees(30), x: 0, y: 1, z: 0)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0)
    expect(CATransform3D.identity.rotate(angle: .degrees(30), x: 0, y: 0, z: 1)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1)

    expect(CATransform3D.identity.rotate(.degrees(30), 1, 0, 0)) == CATransform3D.rotation(angle: .degrees(30), x: 1, y: 0, z: 0)
    expect(CATransform3D.identity.rotate(.degrees(30), 0, 1, 0)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 1, z: 0)
    expect(CATransform3D.identity.rotate(.degrees(30), 0, 0, 1)) == CATransform3D.rotation(angle: .degrees(30), x: 0, y: 0, z: 1)

    expect(CATransform3D.identity.rotate(angle: .degrees(30), axis: .z).affineTransform) == CGAffineTransform(rotationAngle: .degrees(30))
  }

  func test_operation_concat() {
    expect(CATransform3D.identity.concat(CATransform3D.identity)) == CATransform3D.identity
    expect(CATransform3D.identity.concat(CATransform3D.translation(10, 20, 30))) == CATransform3D.translation(10, 20, 30)
    expect(CATransform3D.translation(10, 20, 30).concat(CATransform3D.identity)) == CATransform3D.translation(10, 20, 30)

    expect(
      CATransform3D.translation(10, 20, 30)
        .concat(.translation(10, 20, 30))
        .concat(.translation(10, 20, 30))
    ) == CATransform3D.translation(30, 60, 90)

    expect(
      CATransform3D.translation(10, 20, 0)
        .concat(.rotation(.degrees(30), 0, 0, 1))
        .affineTransform
    ) == CGAffineTransform.rotation(angle: .degrees(30)).translatedBy(x: 10, y: 20)
  }

  // MARK: - Hashable

  func test_hash() {
    expect(CATransform3D.identity.hashValue) == CATransform3DIdentity.hashValue
    let hash1 = CATransform3D.scale(x: 1, y: 2, z: 3).hashValue
    let hash2 = CATransform3D.scale(x: 1, y: 2, z: 3).hashValue
    expect(hash1) == hash2
  }

  // MARK: - Concatenation

  func test_concatenated() {
    // empty
    expect([CATransform3D]().concatenated()) == CATransform3DIdentity

    // single
    expect([CATransform3D.identity].concatenated()) == CATransform3DIdentity

    // non-empty
    expect(
      [
        CATransform3D.identity,
        CATransform3D.identity,
        CATransform3D.scale(x: 10, y: 10, z: 10),
        CATransform3D.translation(x: 10, y: 20, z: 30),
      ].concatenated()
    ) == CATransform3D.translation(x: 10, y: 20, z: 30).scale(x: 10, y: 10, z: 10)
  }
}

#endif

//
//  CGRect+ExtensionsTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-12-09.
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

@testable import ChouTi

class CGRect_ExtensionsTests: XCTestCase {

  // MARK: - Init

  func testInit() {
    do {
      let frame = CGRect(100, 200, 300, 400)
      expect(frame.x) == 100
      expect(frame.y) == 200
      expect(frame.width) == 300
      expect(frame.height) == 400
    }

    do {
      let frame = CGRect(CGPoint(100, 200), CGSize(300, 400))
      expect(frame.x) == 100
      expect(frame.y) == 200
      expect(frame.width) == 300
      expect(frame.height) == 400
    }

    do {
      let frame = CGRect(CGPoint(100, 200), 300)
      expect(frame.x) == 100
      expect(frame.y) == 200
      expect(frame.width) == 300
      expect(frame.height) == 300
    }

    do {
      let frame = CGRect(size: CGSize(300, 400))
      expect(frame.x) == 0
      expect(frame.y) == 0
      expect(frame.width) == 300
      expect(frame.height) == 400
    }

    do {
      let frame = CGRect(CGSize(300, 400))
      expect(frame.x) == 0
      expect(frame.y) == 0
      expect(frame.width) == 300
      expect(frame.height) == 400
    }

    do {
      let frame = CGRect(topLeft: CGPoint(100, 200), bottomRight: CGPoint(100 + 300, 200 + 400))
      expect(frame.x) == 100
      expect(frame.y) == 200
      expect(frame.width) == 300
      expect(frame.height) == 400
    }
  }

  // MARK: - Geometry

  func testX() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.x) == 100

    frame.x = 1000
    expect(frame.x) == 1000
    expect(frame.right) == 1300

    expect(frame.y) == 200
    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testY() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.y) == 200

    frame.y = 1000
    expect(frame.y) == 1000
    expect(frame.bottom) == 1400

    expect(frame.x) == 100
    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testTop() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.top) == 200

    frame.top = 1000
    expect(frame.top) == 1000
    expect(frame.bottom) == 1400

    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testBottom() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.bottom) == 600

    frame.bottom = 1000
    expect(frame.bottom) == 1000
    expect(frame.top) == 600

    frame.bottom = 100
    expect(frame.bottom) == 100
    expect(frame.top) == -300

    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testLeft() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.left) == 100

    frame.left = 1000
    expect(frame.left) == 1000
    expect(frame.right) == 1300

    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testRight() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.right) == 400

    frame.right = 1000
    expect(frame.right) == 1000
    expect(frame.left) == 700

    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testTopLeft() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.topLeft) == CGPoint(x: 100, y: 200)
  }

  func testTopCenter() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.topCenter) == CGPoint(x: 250, y: 200)
  }

  func testTopRight() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.topRight) == CGPoint(x: 400, y: 200)
  }

  func testBottomLeft() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.bottomLeft) == CGPoint(x: 100, y: 600)
  }

  func testBottomCenter() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.bottomCenter) == CGPoint(x: 250, y: 600)
  }

  func testBottomRight() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.bottomRight) == CGPoint(x: 400, y: 600)
  }

  func testLeftCenter() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.leftCenter) == CGPoint(x: 100, y: 400)
  }

  func testRightCenter() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.rightCenter) == CGPoint(x: 400, y: 400)
  }

  func testCenter() {
    var frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.center) == CGPoint(x: 250, y: 400)

    frame.center = CGPoint(x: 150, y: 200)
    expect(frame.origin) == CGPoint.zero
    expect(frame.width) == 300
    expect(frame.height) == 400
  }

  func testFlipped() {
    let frame = CGRect(x: 100, y: 100, width: 300, height: 400)
    expect(frame.flipped(containerHeight: 800)) == CGRect(x: 100, y: 300, width: 300, height: 400)
  }

  // MARK: - Modification

  func testOrigin() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.origin(CGPoint(x: 10, y: 20))) == CGRect(x: 10, y: 20, width: 300, height: 400)
    expect(frame.x(10)) == CGRect(x: 10, y: 200, width: 300, height: 400)
    expect(frame.y(20)) == CGRect(x: 100, y: 20, width: 300, height: 400)
    expect(frame.size(CGSize(width: 100, height: 200))) == CGRect(x: 100, y: 200, width: 100, height: 200)
    expect(frame.width(100)) == CGRect(x: 100, y: 200, width: 100, height: 400)
    expect(frame.height(200)) == CGRect(x: 100, y: 200, width: 300, height: 200)
  }

  // MARK: - Inset & Expand

  func testInset() {
    let frame = CGRect(x: 100, y: 200, width: 300, height: 400)
    expect(frame.inset(by: 10)) == CGRect(x: 110, y: 210, width: 280, height: 380)
    expect(frame.inset(left: 10, right: 20, top: 30, bottom: 40)) == CGRect(x: 110, y: 230, width: 270, height: 330)
    expect(frame.inset()) == frame

    expect(frame.expanded(by: 10)) == CGRect(x: 90, y: 190, width: 320, height: 420)
    expect(frame.expanded(left: 10, right: 20, top: 30, bottom: 40)) == CGRect(x: 90, y: 170, width: 330, height: 470)
    expect(frame.expanded()) == frame

    expect(frame.inset(by: 150)) == CGRect(250.0, 350.0, 0.0, 100.0)
    expect(frame.inset(by: 160)) == CGRect(.infinity, .infinity, 0, 0)
  }

  // MARK: - Translate

  func testTranslate() {
    expect(CGRect(10, 20, 400, 500).translate(dx: 10, dy: 20)) == CGRect(20, 40, 400, 500)
    expect(CGRect(10, 20, 400, 500).translate(dx: 10)) == CGRect(20, 20, 400, 500)
    expect(CGRect(10, 20, 400, 500).translate(dy: 10)) == CGRect(10, 30, 400, 500)
    expect(CGRect(10, 20, 400, 500).translate()) == CGRect(10, 20, 400, 500)

    expect(CGRect(10, 20, 400, 500).translate(CGVector(dx: 20, dy: 30))) == CGRect(30, 50, 400, 500)
    expect(CGRect(10, 20, 400, 500).translate(CGPoint(x: 20, y: 30))) == CGRect(30, 50, 400, 500)
  }

  // MARK: - Scale

  func testScale() {
    expect(CGRect(10, 20, 400, 500) * 2) == CGRect(20, 40, 800, 1000)

    var rect = CGRect(10, 20, 400, 500)
    rect *= 2
    expect(rect) == CGRect(20, 40, 800, 1000)
  }

  // MARK: - Pixel Perfect

  func testRounded() {
    expect(CGRect(10.1, 20.1, 400.12, 500.12).rounded(scaleFactor: 2)) == CGRect(10, 20, 400, 500)
    expect(CGRect(10.4, 20.4, 400.4, 500.4).rounded(scaleFactor: 2)) == CGRect(10.5, 20.5, 400.5, 500.5)

    expect(CGRect(10.1, 20.1, 400.12, 500.12).rounded(scaleFactor: 3)) == CGRect(10, 20, 400, 500)
    expect(CGRect(10.4, 20.4, 400.4, 500.4).rounded(scaleFactor: 3)) == CGRect(10.333333333333334, 20.333333333333332, 400.3333333333333, 500.3333333333333)

    expect(CGRect.null.rounded(scaleFactor: 2)) == CGRect.null
    expect(CGRect.infinite.rounded(scaleFactor: 2)) == CGRect.infinite
  }

  // MARK: - Interpolation

  func testLerpAtStart() {
    let startRect = CGRect(x: 0, y: 0, width: 50, height: 50)
    let endRect = CGRect(x: 10, y: 10, width: 100, height: 100)
    let lerpRect = startRect.lerp(to: endRect, t: 0.0)
    expect(lerpRect) == startRect
  }

  func testLerpAtEnd() {
    let startRect = CGRect(x: 0, y: 0, width: 50, height: 50)
    let endRect = CGRect(x: 10, y: 10, width: 100, height: 100)
    let lerpRect = startRect.lerp(to: endRect, t: 1.0)
    expect(lerpRect) == endRect
  }

  func testLerpAtMiddle() {
    let startRect = CGRect(x: 0, y: 0, width: 50, height: 50)
    let endRect = CGRect(x: 10, y: 10, width: 100, height: 100)
    let lerpRect = startRect.lerp(to: endRect, t: 0.5)
    let expectedRect = CGRect(x: 5, y: 5, width: 75, height: 75)
    expect(lerpRect) == expectedRect
  }

  // MARK: - Intersection

  func testIntersects() {
    // plane (non-zero size), horizontal line, vertical line, point, zero, null, infinite

    // plane (non-zero size)
    do {
      let rect1 = CGRect(10, 20, 10, 10)

      do {
        let rect2 = CGRect(20, 20, 10, 10) // edge touches, non-zero size
        expect(rect1.intersects(rect2)) == false // <---
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect(10, 20, 0, 10) // edge touches, zero width
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect(9.999, 20, 0, 10) // edge doesn't touches, zero width
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect(20, 30, 10, 10) // point touches, non-zero size
        expect(rect1.intersects(rect2)) == false // <---
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect(10, 20, 0, 0) // point touches, zero size
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect(9.999, 20, 0, 0) // point doesn't touches, zero size
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.zero
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    // vertical line (zero width)
    do {
      let rect1 = CGRect(10, 20, 0, 10)

      do {
        // line overlaps
        let rect2 = CGRect(10, 25, 0, 10)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        // touching point
        let rect2 = CGRect(10, 30, 0, 10)
        expect(rect1.intersects(rect2)) == false // <---
        expect(rect1.intersects2(rect2)) == true

        let rect3 = CGRect(10, 30, 10, 0)
        expect(rect1.intersects(rect3)) == false // <---
        expect(rect1.intersects2(rect3)) == true
      }

      do {
        // line doesn't overlap
        let rect2 = CGRect(10, 35, 0, 10)
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      // point
      do {
        let rect2 = CGRect(10, 20, 0, 0)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect.zero
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    // horizontal line (zero height)
    do {
      let rect1 = CGRect(10, 20, 10, 0)

      do {
        // line overlaps
        let rect2 = CGRect(15, 20, 10, 0)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        // touching point
        let rect2 = CGRect(20, 20, 10, 0)
        expect(rect1.intersects(rect2)) == false // <---
        expect(rect1.intersects2(rect2)) == true

        let rect3 = CGRect(20, 20, 0, 10)
        expect(rect1.intersects(rect3)) == false // <---
        expect(rect1.intersects2(rect3)) == true
      }

      do {
        // line doesn't overlap
        let rect2 = CGRect(25, 20, 10, 0)
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      // point
      do {
        let rect2 = CGRect(10, 20, 0, 0)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect.zero
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    // point (zero size)
    do {
      let rect1 = CGRect(10, 20, 0, 0)

      do {
        // point overlaps
        let rect2 = CGRect(10, 20, 0, 0)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      // point doesn't overlap
      do {
        let rect2 = CGRect(10, 21, 0, 0)
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.zero
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    // zero
    do {
      let rect1 = CGRect.zero

      do {
        let rect2 = CGRect(0, 0, 0, 0)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect(-1, -1, 5, 5)
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect.zero
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    // null
    do {
      let rect1 = CGRect.null

      do {
        let rect2 = CGRect.null
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == false
        expect(rect1.intersects2(rect2)) == false
      }
    }

    // infinite
    do {
      let rect1 = CGRect.infinite

      do {
        let rect2 = CGRect.infinite
        expect(rect1.intersects(rect2)) == true
        expect(rect1.intersects2(rect2)) == true
      }
    }

    do {
      let rect1 = CGRect(187.66666666666669, 50.0, 187.66666666666666, 135.66666666666666)
      let rect2 = CGRect(375.3333333333, 50.0, 187.66666666666666, 135.66666666666666) // edge touches
      let rect3 = CGRect(375.3333334333, 50.0, 187.66666666666666, 135.66666666666666) // off by very little

      expect(rect1.intersects(rect2)) == true
      expect(rect1.intersects(rect3)) == false

      expect(rect1.intersects2(rect2)) == true
      expect(rect1.intersects2(rect3)) == false
    }
  }

  func testNonEmptyIntersection() {
    // zero height
    do {
      let zeroHeightRect = CGRect(x: 0, y: 10, width: 100, height: 0)
      let normalRect = CGRect(x: 0, y: 0, width: 100, height: 100)

      expect(zeroHeightRect.intersects(normalRect)) == true
      expect(zeroHeightRect.intersects2(normalRect)) == true

      let intersection = zeroHeightRect.intersection(normalRect)
      expect(intersection.isNull) == false
      expect(intersection.isEmpty) == true

      let nonEmptyIntersection = zeroHeightRect.nonEmptyIntersection(normalRect)
      expect(nonEmptyIntersection) == nil
    }

    // not intersecting
    do {
      let rect1 = CGRect(x: 0, y: 110, width: 100, height: 10)
      let normalRect = CGRect(x: 0, y: 0, width: 100, height: 100)

      expect(rect1.intersects(normalRect)) == false
      expect(rect1.intersects2(normalRect)) == false

      let intersection = rect1.intersection(normalRect)
      expect(intersection.isNull) == true
      expect(intersection.isEmpty) == true

      let nonEmptyIntersection = rect1.nonEmptyIntersection(normalRect)
      expect(nonEmptyIntersection) == nil
    }

    // intersecting
    do {
      let rect1 = CGRect(x: 0, y: 0, width: 100, height: 100)
      let rect2 = CGRect(x: 50, y: 50, width: 100, height: 100)

      expect(rect1.intersects(rect2)) == true
      expect(rect1.intersects2(rect2)) == true

      let intersection = rect1.intersection(rect2)
      expect(intersection.isNull) == false
      expect(intersection.isEmpty) == false

      let nonEmptyIntersection = rect1.nonEmptyIntersection(rect2)
      expect(nonEmptyIntersection) == intersection
      expect(try nonEmptyIntersection.unwrap().isNull) == false
      expect(try nonEmptyIntersection.unwrap().isEmpty) == false
    }
  }

  func testIntersection() {
    // plane
    do {
      let rect1 = CGRect(x: 0, y: 0, width: 100, height: 100)

      // plane (inside)
      do {
        let rect2 = CGRect(x: 10, y: 10, width: 10, height: 10)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect2
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == false

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect2
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == false
      }

      // plane (overlapping)
      do {
        let rect2 = CGRect(x: -50, y: -25, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(x: 0, y: 0, width: 50, height: 75)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == false

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(x: 0, y: 0, width: 50, height: 75)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == false
      }

      // plane (edge touches)
      do {
        let rect2 = CGRect(x: 50, y: 100, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(50.0, 100.0, 50.0, 0.0)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(50.0, 100.0, 50.0, 0.0)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (point touches)
      do {
        let rect2 = CGRect(x: 100, y: 100, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(100.0, 100.0, 0.0, 0.0)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(100.0, 100.0, 0.0, 0.0)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (not intersecting, x)
      do {
        let rect2 = CGRect(x: 101, y: 100, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // plane (not intersecting, y)
      do {
        let rect2 = CGRect(x: 100, y: 101, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // zero
      do {
        let rect2 = CGRect.zero
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.zero
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.zero
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        var intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == false

        intersection = rect2.intersection2(rect1)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == false

        var intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == false

        intersection2 = rect2.intersection2(rect1)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == false
      }
    }

    // vertical line
    do {
      let rect1 = CGRect(x: 10, y: 20, width: 0, height: 100)

      // plane (touching edge)
      do {
        let rect2 = CGRect(x: 10, y: 20, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (overlapping)
      do {
        let rect2 = CGRect(x: 5, y: 10, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(x: 10, y: 20, width: 0, height: 90)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(x: 10, y: 20, width: 0, height: 90)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (touching point)
      do {
        let rect2 = CGRect(x: 10, y: 120, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(x: 10, y: 120, width: 0, height: 0)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(x: 10, y: 120, width: 0, height: 0)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (not intersecting)
      do {
        let rect2 = CGRect(x: 10, y: 121, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // zero
      do {
        let rect2 = CGRect.zero
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.null
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.null
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }
    }

    // horizontal line
    do {
      let rect1 = CGRect(x: 10, y: 20, width: 100, height: 0)

      // plane (touching edge)
      do {
        let rect2 = CGRect(x: 10, y: 20, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (overlapping)
      do {
        let rect2 = CGRect(x: -50, y: -25, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(x: 10, y: 20, width: 40, height: 0)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(x: 10, y: 20, width: 40, height: 0)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (touching point)
      do {
        let rect2 = CGRect(x: 110, y: 20, width: 0, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(x: 110, y: 20, width: 0, height: 0)
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection) == CGRect(x: 110, y: 20, width: 0, height: 0)
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // plane (not intersecting)
      do {
        let rect2 = CGRect(x: 10, y: 121, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect(.infinity, .infinity, 0, 0)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // zero
      do {
        let rect2 = CGRect.zero
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.null
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.null
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }
    }

    // point
    do {
      let rect1 = CGRect(x: 10, y: 20, width: 0, height: 0)

      // plane
      do {
        let rect2 = CGRect(x: 10, y: 20, width: 100, height: 100)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // line
      do {
        let rect2 = CGRect(x: 10, y: 20, width: 100, height: 0)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // point
      do {
        let rect2 = CGRect(x: 10, y: 20, width: 0, height: 0)
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // zero
      do {
        let rect2 = CGRect.zero
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.null
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.null
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }
    }

    // zero
    do {
      let rect1 = CGRect.zero

      // zero
      do {
        let rect2 = CGRect.zero
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.zero
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.zero
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == true
      }
    }

    // null
    do {
      let rect1 = CGRect.null

      // null
      do {
        let rect2 = CGRect.null
        let intersection = rect1.intersection(rect2)
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == rect1
        expect(intersection.isNull) == true
        expect(intersection.isEmpty) == true

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == rect1
        expect(intersection2.isNull) == true
        expect(intersection2.isEmpty) == true
      }
    }

    // infinite
    do {
      let rect1 = CGRect.infinite

      // infinite
      do {
        let rect2 = CGRect.infinite
        let intersection = rect1.intersection(rect2)
        expect(intersection) == CGRect.infinite
        expect(intersection.isNull) == false
        expect(intersection.isEmpty) == false

        let intersection2 = rect1.intersection2(rect2)
        expect(intersection2) == CGRect.infinite
        expect(intersection2.isNull) == false
        expect(intersection2.isEmpty) == false
      }
    }

    do {
      let pixelSize = 1 / CGFloat(3)
      let absoluteTolerance = pixelSize + 1e-12

      let rect1 = CGRect(0.0, 0.0, 375.0, 728.0)
      let rect2 = CGRect(187.66666666666669, 50.0, 187.66666666666666, 135.66666666666666)
      let foundationIntersection = rect1.intersection(rect2)
      expect(foundationIntersection.x) == 187.66666666666669
      expect(foundationIntersection.y) == 50.0
      expect(foundationIntersection.width) == 187.33333333333331 // <-- screen width is not enough
      expect(foundationIntersection.height) == 135.66666666666666

      let chouTiIntersection = rect1.intersection2(rect2)
      expect(chouTiIntersection.x) == 187.66666666666669
      expect(chouTiIntersection.y) == 50.0
      expect(chouTiIntersection.width) == 187.33333333333331 // <-- screen width is not enough
      expect(chouTiIntersection.height) == 135.66666666666666

      let rect = CGRect(x: 100.33333333333333333333333, y: 0, width: 100, height: 100)
      let infinite = CGRect.infinite
      var intersection = infinite.intersection(rect)
      expect(infinite.contains(rect)) == true
      expect(intersection == rect) == false // <--- false?

      let intersection2 = infinite.intersection2(rect)
      expect(infinite.contains(rect)) == true
      expect(intersection2 == rect) == true

      let otherRect = CGRect(x: 0, y: 0, width: 400, height: 400)
      intersection = otherRect.intersection2(rect)
      expect(otherRect.contains(rect)) == true
      expect(intersection.isApproximatelyEqual(to: rect, absoluteTolerance: absoluteTolerance)) == true
    }
  }

  func testApproximatelyContains() {
    let rect1 = CGRect(x: 10, y: 110, width: 100, height: 10)
    var rect2 = CGRect(x: 10, y: 110, width: 99, height: 10)
    expect(rect1.approximatelyContains(rect2, absoluteTolerance: 0.1)) == true

    rect2 = CGRect(x: 10, y: 110, width: 100, height: 9)
    expect(rect1.approximatelyContains(rect2, absoluteTolerance: 0.1)) == true

    rect2 = CGRect(x: 10, y: 110, width: 100, height: 10)
    expect(rect1.approximatelyContains(rect2, absoluteTolerance: 0.1)) == true

    rect2 = CGRect(x: 10, y: 110, width: 100, height: 10.1)
    expect(rect1.approximatelyContains(rect2, absoluteTolerance: 0.1)) == true

    rect2 = CGRect(x: 10, y: 110, width: 100, height: 10.2)
    expect(rect1.approximatelyContains(rect2, absoluteTolerance: 0.1)) == false
  }

  // MARK: - Misc

  func testSquareRect() {
    let rect = CGRect(x: 10, y: 10, width: 200, height: 100)
    expect(rect.squareRect()) == CGRect(x: 50, y: 00, width: 100, height: 100)
  }

  func testAspectRatio() {
    let rect = CGRect(x: 10, y: 10, width: 200, height: 100)
    expect(rect.aspectRatio) == 2

    do {
      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "Getting aspect ratio with zero height."
        expect(metadata) == ["width": "0.0", "height": "0.0"]
      }

      expect(CGRect.zero.aspectRatio) == .greatestFiniteMagnitude
      expect(CGRect.null.aspectRatio) == .greatestFiniteMagnitude

      Assert.resetTestAssertionFailureHandler()
    }

    expect(CGRect.infinite.aspectRatio) == 1
  }

  func testShape() {
    expect(CGRect(10, 10, 200, 100).isPortrait) == false
    expect(CGRect.zero.isPortrait) == true
    expect(CGRect.null.isPortrait) == true
    expect(CGRect.infinite.isPortrait) == true

    expect(CGRect(10, 10, 200, 100).isLandScape) == true
    expect(CGRect.zero.isLandScape) == false
    expect(CGRect.null.isLandScape) == false
    expect(CGRect.infinite.isLandScape) == false

    expect(CGRect(10, 10, 200, 100).isSquare) == false
    expect(CGRect.zero.isSquare) == true
    expect(CGRect.null.isSquare) == true
    expect(CGRect.infinite.isSquare) == false
  }

  func testApproximatelyEqual() {
    let pixelSize = 1 / CGFloat(3)
    let absoluteTolerance = pixelSize + 1e-12

    let rect1 = CGRect(187.66666666666669, 50.0, 187.33333333333331, 135.66666666666666)
    let rect2 = CGRect(187.66666666666669, 50.0, 187.66666666666666, 135.66666666666666)
    expect(rect1.isApproximatelyEqual(to: rect2, absoluteTolerance: absoluteTolerance)) == true
  }

  func testHashable() {
    let rect1 = CGRect(187.66666666666669, 50.0, 187.33333333333331, 135.66666666666666)
    let rect2 = CGRect(187.66666666666669, 50.0, 187.33333333333331, 135.66666666666666)
    expect(rect1.hashValue) == rect2.hashValue
  }
}

//
//  CGAffineTransformBuilderTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/31/21.
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

class CGAffineTransformBuilderTests: XCTestCase {

  private func make(@CGAffineTransformBuilder affineTransformBuilder: () -> [CGAffineTransform]) -> [CGAffineTransform] {
    return affineTransformBuilder()
  }

  func test() {
    let array = make {
      CGAffineTransform.identity
      CGAffineTransform.identity
    }
    expect(array) == [CGAffineTransform.identity, CGAffineTransform.identity]
  }

  func test_if() {
    var flag = true
    let array = make {
      if flag {
        CGAffineTransform.identity
      } else {
        CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
      }
    }
    expect(array) == [CGAffineTransform.identity]

    flag = false
    let array2 = make {
      if flag {
        CGAffineTransform.identity
      } else {
        CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)
      }
    }
    expect(array2) == [CGAffineTransform(a: 1, b: 2, c: 3, d: 4, tx: 5, ty: 6)]
  }
}

//
//  Data+HashTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/16/22.
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

class Data_HashTests: XCTestCase {

  func test_md5() {
    let md5Checksum = "hello world".utf8Data().md5()
    expect(md5Checksum) == "5eb63bbbe01eeed093cb22bb8f5acdc3"

    let md5ChecksumEmpty = "".utf8Data().md5()
    expect(md5ChecksumEmpty) == "d41d8cd98f00b204e9800998ecf8427e"
  }

  func test_sha1() {
    let sha1Hash = "hello world".utf8Data().sha1()
    expect(sha1Hash) == "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed"
  }

  func test_sha256() {
    let sha256Hash = "hello world".utf8Data().sha256()
    expect(sha256Hash) == "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
  }

  func test_sha512() {
    let sha512Hash = "hello world".utf8Data().sha512()
    expect(sha512Hash) == "309ecc489c12d6eb4cc40f50c902f2b4d0ed77ee511a7c7a9bcd3ca86d4cd86f989dd35bc5ff499670da34255b45b0cfd830e81f605dcf7dc5542e93ae9cd76f"
  }
}

//
//  ContinuationTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 6/3/24.
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

final class ContinuationTests: XCTestCase {

  func testContinuationResumeReturning() async {
    do {
      let expectedValue = "Test"

      let result = await withContinuation { (continuation: Continuation<String, Never>) in
        continuation.resume(returning: expectedValue)
      }

      expect(result) == expectedValue
    }
    do {
      let expectedValue = "Test"
      let result = try? await withThrowingContinuation { (continuation: Continuation<String, Error>) in
        continuation.resume(returning: "Test")
      }
      expect(result) == expectedValue
    }
  }

  func testContinuationResumeThrowing() async {
    let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil) as Error

    do {
      _ = try await withThrowingContinuation { (continuation: Continuation<String, Error>) in
        continuation.resume(throwing: expectedError)
      }
      fail("The continuation should have thrown an error")
    } catch {
      expect(error as NSError) == expectedError as NSError
    }
  }

  func testContinuationResumeWithResultSuccess() async {
    let expectedValue = "Success"

    let result = await withContinuation { (continuation: Continuation<String, Never>) in
      continuation.resume(with: .success(expectedValue))
    }

    expect(result) == expectedValue
  }

  func testContinuationResumeWithResultFailure() async {
    let expectedError = NSError(domain: "TestError", code: 1, userInfo: nil) as Error

    do {
      _ = try await withThrowingContinuation { (continuation: Continuation<String, Error>) in
        continuation.resume(with: .failure(expectedError))
      }
      fail("The continuation should have thrown an error")
    } catch {
      expect(error as NSError) == expectedError as NSError
    }
  }

  func testContinuationResumeWithResultFailure2() async {
    let expectedError = ChouTi.RuntimeError.empty

    do {
      _ = try await withThrowingContinuation { (continuation: Continuation<String, Error>) in
        continuation.resume(with: .failure(ChouTi.RuntimeError.empty))
      }
      fail("The continuation should have thrown an error")
    } catch {
      expect(error as NSError) == expectedError as NSError
    }
  }

  func testContinuationResumeWithResultFailure3() async {
    enum SomeError: Swift.Error {
      case someError
    }

    func callWithCompletion(completion: (Result<String, SomeError>) -> Void) {
      completion(.failure(.someError))
    }

    let expectedError = SomeError.someError

    do {
      _ = try await withThrowingContinuation { continuation in
        callWithCompletion { result in
          continuation.resume(with: result)
        }
      }
      fail("The continuation should have thrown an error")
    } catch {
      expect(error as NSError) == expectedError as NSError
    }
  }

  func testContinuationResumeReturningVoid() async {
    await withContinuation { (continuation: Continuation<Void, Never>) in
      continuation.resume()
    }
  }

  func testContinuationResumeReturningValueForNeverError() async {
    let expectedValue = "Test"

    let result = await withContinuation { (continuation: Continuation<String, Never>) in
      continuation.resume(returning: expectedValue)
    }

    expect(result) == expectedValue
  }

  func testContinuationResumeReturningValue() async {
    let expectedValue = "Test"

    let result = await withContinuation { (continuation: Continuation<String, Never>) in
      continuation.resume(returning: expectedValue)
    }

    expect(result) == expectedValue
  }
}

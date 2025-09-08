//
//  EnvironmentTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 9/8/25.
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

class EnvironmentTests: XCTestCase {

  override func setUp() {
    super.setUp()
    clearCIEnvironmentVariables()
  }

  override func tearDown() {
    clearCIEnvironmentVariables()
    super.tearDown()
  }

  // MARK: - isGitHubActions Tests

  func test_isGitHubActions_whenGitHubActionsIsTrue_returnsTrue() {
    // given
    setenv("GITHUB_ACTIONS", "true", 1)

    // when & then
    expect(Environment.isGitHubActions) == true
  }

  func test_isGitHubActions_whenGitHubActionsIsFalse_returnsFalse() {
    // given
    setenv("GITHUB_ACTIONS", "false", 1)

    // when & then
    expect(Environment.isGitHubActions) == false
  }

  func test_isGitHubActions_whenGitHubActionsIsEmpty_returnsFalse() {
    // given
    setenv("GITHUB_ACTIONS", "", 1)

    // when & then
    expect(Environment.isGitHubActions) == false
  }

  func test_isGitHubActions_whenGitHubActionsIsNotSet_returnsFalse() {
    // given
    unsetenv("GITHUB_ACTIONS")

    // when & then
    expect(Environment.isGitHubActions) == false
  }

  func test_isGitHubActions_whenGitHubActionsIsOtherValue_returnsFalse() {
    // given
    setenv("GITHUB_ACTIONS", "yes", 1)

    // when & then
    expect(Environment.isGitHubActions) == false
  }

  // MARK: - isCI Tests

  func test_isCI_whenCIIsTrue_returnsTrue() {
    // given
    setenv("CI", "true", 1)

    // when & then
    expect(Environment.isCI) == true
  }

  func test_isCI_whenContinuousIntegrationIsTrue_returnsTrue() {
    // given
    setenv("CONTINUOUS_INTEGRATION", "true", 1)

    // when & then
    expect(Environment.isCI) == true
  }

  func test_isCI_whenGitHubActionsIsTrue_returnsTrue() {
    // given
    setenv("GITHUB_ACTIONS", "true", 1)

    // when & then
    expect(Environment.isCI) == true
  }

  func test_isCI_whenMultipleCIVariablesAreTrue_returnsTrue() {
    // given
    setenv("CI", "true", 1)
    setenv("CONTINUOUS_INTEGRATION", "true", 1)
    setenv("GITHUB_ACTIONS", "true", 1)

    // when & then
    expect(Environment.isCI) == true
  }

  func test_isCI_whenOnlyOneOfMultipleCIVariablesIsTrue_returnsTrue() {
    // given
    setenv("CI", "false", 1)
    setenv("CONTINUOUS_INTEGRATION", "true", 1)
    setenv("GITHUB_ACTIONS", "false", 1)

    // when & then
    expect(Environment.isCI) == true
  }

  func test_isCI_whenCIIsFalse_returnsFalse() {
    // given
    setenv("CI", "false", 1)

    // when & then
    expect(Environment.isCI) == false
  }

  func test_isCI_whenContinuousIntegrationIsFalse_returnsFalse() {
    // given
    setenv("CONTINUOUS_INTEGRATION", "false", 1)

    // when & then
    expect(Environment.isCI) == false
  }

  func test_isCI_whenAllCIVariablesAreFalse_returnsFalse() {
    // given
    setenv("CI", "false", 1)
    setenv("CONTINUOUS_INTEGRATION", "false", 1)
    setenv("GITHUB_ACTIONS", "false", 1)

    // when & then
    expect(Environment.isCI) == false
  }

  func test_isCI_whenNoCIVariablesAreSet_returnsFalse() {
    // given
    unsetenv("CI")
    unsetenv("CONTINUOUS_INTEGRATION")
    unsetenv("GITHUB_ACTIONS")

    // when & then
    expect(Environment.isCI) == false
  }

  func test_isCI_whenCIVariablesHaveOtherValues_returnsFalse() {
    // given
    setenv("CI", "yes", 1)
    setenv("CONTINUOUS_INTEGRATION", "1", 1)
    setenv("GITHUB_ACTIONS", "on", 1)

    // when & then
    expect(Environment.isCI) == false
  }

  // MARK: - Helper Methods

  private func clearCIEnvironmentVariables() {
    unsetenv("CI")
    unsetenv("CONTINUOUS_INTEGRATION")
    unsetenv("GITHUB_ACTIONS")
  }
}

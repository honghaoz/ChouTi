//
//  KVOObserverTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/14/23.
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

import Foundation

import ChouTiTest

import ChouTi

class KVOObserverTests: XCTestCase {

  private let testQueue = DispatchQueue.make(label: "KVOObserverTests")

  private var person: Person!
  private var observer: KVOObserver<Person, String>!

  override func tearDown() {
    person = nil
    observer = nil
  }

  func test_objectIsWeaklyRetained() {
    person = Person(name: "Ryan", age: 20)
    weak var weakPersonRef: Person? = person

    observer = KVOObserver(object: person, keyPath: "name") { _, _, _ in }

    expect(person) != nil
    expect(weakPersonRef) != nil

    person = nil

    expect(weakPersonRef) == nil
  }

  func test_observation() {
    let expectation = XCTestExpectation(description: "KVO triggered")
    let expectation2 = XCTestExpectation(description: "KVO triggered")

    person = Person(name: "Ryan", age: 20)

    // print("Class BEFORE observing: \(String(cString: class_getName(object_getClass(person))))")
    // Class BEFORE observing: _TtC11ChouTiTestsP33_C3EC5C8909442460ED1D012CEEBDF1306Person

    var nameCount = 0
    observer = KVOObserver(object: person, keyPath: "name") { object, old, new in
      nameCount += 1
      if old == "Ryan", new == "Mike" {
        expectation.fulfill()
      }
    }

    var ageCount = 0
    let observer2 = KVOObserver<Person, Int>(object: person, keyPath: "age") { object, old, new in
      ageCount += 1
      if old == 20, new == 21 {
        expectation2.fulfill()
      }
    }
    _ = observer2

    // print("Class AFTER observing: \(String(cString: class_getName(object_getClass(person))))")
    // Class AFTER observing: NSKVONotifying__TtC11ChouTiTestsP33_C3EC5C8909442460ED1D012CEEBDF1306Person

    person.name = "Mike"
    expect(nameCount) == 1
    expect(ageCount) == 0

    person.age = 21
    expect(nameCount) == 1
    expect(ageCount) == 1

    wait(for: [expectation, expectation2], timeout: 1)
  }

  func test_observation_pause_resume() {
    person = Person(name: "Ryan", age: 20)

    var triggerCount = 0
    observer = KVOObserver(object: person, keyPath: "name") { object, old, new in
      triggerCount += 1
    }

    expect(triggerCount) == 0

    person.name = "Mike"
    expect(triggerCount) == 1

    observer.pause()
    person.name = "Jack"
    expect(triggerCount) == 1

    observer.resume()
    person.name = "John"
    expect(triggerCount) == 2

    // double pause
    observer.pause()
    observer.pause()
    person.name = "Doe"
    expect(triggerCount) == 2

    // double resume
    observer.resume()
    observer.resume()
    person.name = "Doe"
    expect(triggerCount) == 3
  }

  func test_observation_stop() {
    let expectation = XCTestExpectation(description: "KVO triggered")
    expectation.isInverted = true

    person = Person(name: "Ryan", age: 20)

    observer = KVOObserver(object: person, keyPath: "name") { object, old, new in
      expectation.fulfill()
    }

    observer?.stop()
    person.name = "Jack"

    wait(for: [expectation], timeout: 0.02)

    // stop again
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "KVO observation has stopped."
      expect(metadata) == [
        "object": String(describing: self.person),
        "keyPath": "name",
      ]
    }

    observer?.stop()
    person.name = "John"

    Assert.resetTestAssertionFailureHandler()

    // resume after stopped
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "You cannot resume a KVO observer that has been stopped."
      expect(metadata) == [
        "object": String(describing: self.person),
        "keyPath": "name",
      ]
    }

    observer?.resume()
    person.name = "Doe"

    Assert.resetTestAssertionFailureHandler()

    // pause after stopped
    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "You cannot pause a KVO observer that has been stopped."
      expect(metadata) == [
        "object": String(describing: self.person),
        "keyPath": "name",
      ]
    }

    observer?.pause()
    person.name = "Doe"

    Assert.resetTestAssertionFailureHandler()
  }

  func test_observation_rawRepresentable() {
    person = Person(name: "Ryan", age: 20)

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == "KVOObserver: failed to get changed values"
      expect(metadata["object"]) == "\(self.person!)" // swiftlint:disable:this force_unwrapping
      expect(metadata["keyPath"]) == "status"
      expect(metadata["observerType"]) == "KVOObserver<Person, Status>"
      expect(metadata["change"]) != nil
    }

    let observer = KVOObserver<Person, Person.Status>(object: person, keyPath: "status") { _, _, _ in }
    _ = observer

    person.status = .busy

    Assert.resetTestAssertionFailureHandler()
  }
}

private class Person: NSObject {

  @objc dynamic var name: String
  @objc dynamic var age: Int

  @objc enum Status: Int {
    case free
    case busy
  }

  @objc dynamic var status: Status = .free

  init(name: String, age: Int) {
    self.name = name
    self.age = age
  }
}

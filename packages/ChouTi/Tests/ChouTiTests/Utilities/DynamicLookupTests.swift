//
//  DynamicLookupTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 8/30/24.
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

private class Person {

  private class Brain {

    private let size: Float

    init(size: Float) {
      self.size = size
    }
  }

  private let name: String
  private let age: Int
  private let brain: Brain

  private lazy var ageString: String = "Age: \(age)"

  init(name: String, age: Int) {
    self.name = name
    self.age = age
    self.brain = Brain(size: 100)
  }

  func triggerLazyProperty() {
    _ = ageString
  }
}

class DynamicLookupTests: XCTestCase {

  func test_optional() {
    let person: Person? = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person as Any)
    expect(lookup.name) == "John"
    expect(lookup.age) == 30

    let nilPerson: Person? = nil
    let nilLookup = DynamicLookup(nilPerson as Any)
    expect(nilLookup.property("name")) == nil
    expect(nilLookup.property("age")) == nil
    expect(nilLookup.property("brain")) == nil
    expect(nilLookup.property("ageString")) == nil
  }

  func test_subscript() {
    let person = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person)
    expect(lookup.name) == "John"
    expect(lookup.age) == 30

    person.triggerLazyProperty()
    expect(lookup.ageString) == "Age: 30"
  }

  func test_propertyNames() {
    let person = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person)
    expect(lookup.propertyNames()) == ["name", "age", "brain", "$__lazy_storage_$_ageString"]
  }

  func test_property() {
    let person = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person)
    expect(lookup.property("name")) == "John"
    expect(lookup.property("age")) == 30
  }

  func test_lazyProperty() {
    let person = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person)

    // lazy property is not initialized yet
    expect(lookup.lazyProperty<String>("ageString")) == nil
    expect(lookup.lazyProperty("ageString")) == nil
    expect(lookup.lazyProperty("ageString") == nil) == false
    expect(lookup.lazyProperty("ageString")! == nil) == true // swiftlint:disable:this force_unwrapping

    // trigger lazy property
    person.triggerLazyProperty()
    expect(lookup.lazyProperty("ageString")) == "Age: 30"
  }

  func test_keyPath() {
    let person = Person(name: "John", age: 30)
    let lookup = DynamicLookup(person)
    expect(lookup.keyPath("brain.size") as? Float) == 100

    let size: Float? = lookup.keyPath("brain.size")
    expect(size) == 100

    // non-existing key path
    expect(lookup.keyPath("foo.bar.someString") as? String) == nil
  }
}

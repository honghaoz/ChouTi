//
//  TypeTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/16/21.
//  Copyright © 2020 Honghao Zhang (github.com/honghaoz).
//
//  MIT License
//
//  Copyright (c) 2020 Honghao Zhang
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

class TypeNameTests: XCTestCase {

  private struct Foo: Hashable {}

  func testTypeName() {
    expect(typeName(Foo.self)) == "Foo"
    expect(typeName(Foo())) == "Foo"

    expect(typeName([Foo].self)) == "Array<Foo>"
    expect(typeName([Foo]())) == "Array<Foo>"
    expect(typeName([Foo.self])) == "Array<Foo.Type>"

    expect(typeName(Set<Foo>.self)) == "Set<Foo>"
    expect(typeName(Set<Foo>())) == "Set<Foo>"
    expect(typeName(Set<[Foo]>.self)) == "Set<Array<Foo>>"

    expect(typeName([Foo: Int].self)) == "Dictionary<Foo, Int>"
    expect(typeName([Foo: Int].self)) == "Dictionary<Foo, Int>"
    expect(typeName([Foo: Int]())) == "Dictionary<Foo, Int>"
  }

  func testIsNotArray() {

    func foo<M: FooType>() -> M {
      expect(isArrayType(M.self)) == false
      return 2 as! M // swiftlint:disable:this force_cast
    }

    let dummy: Int = foo()
    expect(dummy) == 2
  }

  func testIsArray() {

    func foo<M: FooType>() -> M {
      expect(isArrayType(M.self)) == true
      return [2] as! M // swiftlint:disable:this force_cast
    }

    let dummy: [Int] = foo()
    expect(dummy) == [2]
  }

  func testIsSet() {

    func foo<M: FooType>() -> M {
      expect(isSetType(M.self)) == true
      return Set([2]) as! M // swiftlint:disable:this force_cast
    }

    let dummy: Set<Int> = foo()
    expect(dummy) == [2]
  }

  func testIsDictionary() {

    func foo<M: FooType>() -> M {
      expect(isDictionaryType(M.self)) == true
      return [2: "a"] as! M // swiftlint:disable:this force_cast
    }

    let dummy: [Int: String] = foo()
    expect(dummy) == [2: "a"]
  }

  func test_isOptionalType() {
    expect(isOptionalType(Int?.self)) == true
    expect(isOptionalType(Int.self)) == false
  }

  func test_isReferenceType() {

    class MyClass {}
    let object = MyClass()
    expect(isReferenceType(object)) == true

    struct MyStruct {}
    let structure = MyStruct()
    expect(isReferenceType(structure)) == false

    enum MyEnum { case caseOne
      case caseTwo
    }
    let enumeration = MyEnum.caseOne
    expect(isReferenceType(enumeration)) == false

    let number: Int = 123
    expect(isReferenceType(number)) == false

    let string = "string"
    expect(isReferenceType(string)) == false

    let nsstring: NSString = "string"
    expect(isReferenceType(nsstring)) == true
  }

  func testClassName() {
    expect(getClassName(Foo())) == "__SwiftValue"
    expect(getClassName(NSObject())) == "NSObject"

    let error = NSError(domain: "", code: 1, userInfo: nil)
    expect(getClassName(error)) == "NSError"

    // MARK: - Error Mock

    enum Error: Swift.Error {
      case badURLString
    }

    expect(getClassName(Error.badURLString)) == "__SwiftNativeNSError"

    #if os(macOS)
    let window = NSWindow(
      contentRect: CGRect(x: 0, y: 0, width: 600, height: 600),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: true
    )
    let closeButton = window.standardWindowButton(.closeButton)
    expect(getClassName(closeButton)) == "_NSThemeCloseWidget"
    #endif
  }
}

private protocol FooType {}
extension Int: FooType {}

// MARK: - Make [FooType] conform to FooType

extension Array: FooType where Element: FooType {}
extension Set: FooType where Element: FooType {}
extension Dictionary: FooType {}

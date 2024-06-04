//
//  TypeTests.swift
//
//  Created by Honghao Zhang on 5/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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

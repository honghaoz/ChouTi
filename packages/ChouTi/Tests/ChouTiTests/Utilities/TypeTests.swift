//
//  TypeTests.swift
//
//  Created by Honghao Zhang on 5/16/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

import XCTest
import ChouTiTest

import ChouTi

class TypeNameTests: XCTestCase {

  private struct Foo: Hashable {}

  func testTypeName() {
    expect(typeName(Foo.self)) == "Foo"
    XCTAssertEqual(typeName(Foo()), "Foo")

    XCTAssertEqual(typeName([Foo].self), "Array<Foo>")
    XCTAssertEqual(typeName([Foo]()), "Array<Foo>")
    XCTAssertEqual(typeName([Foo.self]), "Array<Foo.Type>")

    XCTAssertEqual(typeName(Set<Foo>.self), "Set<Foo>")
    XCTAssertEqual(typeName(Set<Foo>()), "Set<Foo>")
    XCTAssertEqual(typeName(Set<[Foo]>.self), "Set<Array<Foo>>")

    XCTAssertEqual(typeName([Foo: Int].self), "Dictionary<Foo, Int>")
    XCTAssertEqual(typeName([Foo: Int].self), "Dictionary<Foo, Int>")
    XCTAssertEqual(typeName([Foo: Int]()), "Dictionary<Foo, Int>")
  }

  func testIsNotArray() {

    func foo<M: FooType>() -> M {
      XCTAssertFalse(isArrayType(M.self))
      return 2 as! M // swiftlint:disable:this force_cast
    }

    let dummy: Int = foo()
    XCTAssertEqual(dummy, 2)
  }

  func testIsArray() {

    func foo<M: FooType>() -> M {
      XCTAssertTrue(isArrayType(M.self))
      return [2] as! M // swiftlint:disable:this force_cast
    }

    let dummy: [Int] = foo()
    XCTAssertEqual(dummy, [2])
  }

  func testIsSet() {

    func foo<M: FooType>() -> M {
      XCTAssertTrue(isSetType(M.self))
      return Set([2]) as! M // swiftlint:disable:this force_cast
    }

    let dummy: Set<Int> = foo()
    XCTAssertEqual(dummy, [2])
  }

  func testIsDictionary() {

    func foo<M: FooType>() -> M {
      XCTAssertTrue(isDictionaryType(M.self))
      return [2: "a"] as! M // swiftlint:disable:this force_cast
    }

    let dummy: [Int: String] = foo()
    XCTAssertEqual(dummy, [2: "a"])
  }

  func test_isOptionalType() {
    expect(isOptionalType(Int?.self)) == true
    expect(isOptionalType(Int.self)) == false
  }

  func test_isReferenceType() {

    class MyClass {}
    let object = MyClass()
    XCTAssertTrue(isReferenceType(object))

    struct MyStruct {}
    let structure = MyStruct()
    XCTAssertFalse(isReferenceType(structure))

    enum MyEnum { case caseOne
      case caseTwo
    }
    let enumeration = MyEnum.caseOne
    XCTAssertFalse(isReferenceType(enumeration))

    let number: Int = 123
    XCTAssertFalse(isReferenceType(number))

    let string = "string"
    XCTAssertFalse(isReferenceType(string))

    let nsstring: NSString = "string"
    XCTAssertTrue(isReferenceType(nsstring))
  }

  func testClassName() {
    XCTAssertEqual(getClassName(Foo()), "__SwiftValue")
    XCTAssertEqual(getClassName(NSObject()), "NSObject")

    let error = NSError(domain: "", code: 1, userInfo: nil)
    XCTAssertEqual(getClassName(error), "NSError")

    // MARK: - Error Mock

    enum Error: Swift.Error {
      case badURLString
    }

    XCTAssertEqual(getClassName(Error.badURLString), "__SwiftNativeNSError")

    #if os(macOS)
    let window = NSWindow(
      contentRect: CGRect(x: 0, y: 0, width: 600, height: 600),
      styleMask: [.titled, .closable, .miniaturizable],
      backing: .buffered,
      defer: true
    )
    let closeButton = window.standardWindowButton(.closeButton)
    XCTAssertEqual(getClassName(closeButton), "_NSThemeCloseWidget")
    #endif
  }
}

private protocol FooType {}
extension Int: FooType {}

// MARK: - Make [FooType] conform to FooType

extension Array: FooType where Element: FooType {}
extension Set: FooType where Element: FooType {}
extension Dictionary: FooType {}

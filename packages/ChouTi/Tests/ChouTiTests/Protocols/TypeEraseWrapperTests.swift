//
//  TypeEraseWrapperTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 1/5/24.
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

class TypeEraseWrapperTests: XCTestCase {

  private protocol Animal: TypeEraseWrapperBaseType {}

  private struct AnyAnimal: Animal, TypeEraseWrapper {

    let wrapped: any Animal
  }

  private struct Dog: Animal {

    let name: String
  }

  func test() {
    let dog = Dog(name: "Rex")
    let anyAnimal: any Animal = AnyAnimal(wrapped: dog)
    expect(anyAnimal as? Dog) == nil
    expect(anyAnimal.as(Dog.self)) != nil

    expect(anyAnimal.as(Animal.self)) != nil
    expect(anyAnimal.as(AnyAnimal.self)) != nil
    expect(anyAnimal.as(Int.self)) == nil

    expect(anyAnimal.is(Dog.self)) == true
    expect(anyAnimal.is(Animal.self)) == true
    expect(anyAnimal.is(AnyAnimal.self)) == true
    expect(anyAnimal.is(Int.self)) == false
  }
}

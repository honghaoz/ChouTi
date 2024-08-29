//
//  AssociatedObjectTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import ChouTiTest

import ChouTi

class AssociatedObjectTests: XCTestCase {

  private enum AssociateKey {
    static var fooKey: UInt8 = 0
  }

  func testAssociationPolicy() {
    expect(AssociationPolicy.strong.associationPolicy) == .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    expect(AssociationPolicy.strongAtomic.associationPolicy) == .OBJC_ASSOCIATION_RETAIN
    expect(AssociationPolicy.copy.associationPolicy) == .OBJC_ASSOCIATION_COPY_NONATOMIC
    expect(AssociationPolicy.copyAtomic.associationPolicy) == .OBJC_ASSOCIATION_COPY
    expect(AssociationPolicy.weak.associationPolicy) == .OBJC_ASSOCIATION_ASSIGN
  }

  func testSetAssociatedObject_strong() {
    let hostObject = NSObject()
    let value = NSObject()
    hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey)
    expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? NSObject) === value
  }

  func testSetAssociatedObject_strongAtomic() {
    let hostObject = NSObject()
    let value = NSObject()
    hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey, associationPolicy: .strongAtomic)
    expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? NSObject) === value
  }

  func testSetAssociatedObject_copy() {
    let hostObject = NSObject()
    let value = "foo"
    hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey, associationPolicy: .copy)
    expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? String) == value
  }

  func testSetAssociatedObject_copyAtomic() {
    let hostObject = NSObject()
    let value = "foo"
    hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey, associationPolicy: .copyAtomic)
    expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? String) == value
  }

  func testSetAssociatedObject_weak() {
    let hostObject = NSObject()
    let value = NSObject()

    Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
      expect(message) == ".weak association policy is unsafe, use `setWeakAssociatedObject(_:for:)` & `getWeakAssociatedObject(_:for:)`"
    }

    hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey, associationPolicy: .weak)
    expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey)) == nil

    Assert.resetTestAssertionFailureHandler()
  }

  func testRemoveAssociatedObject() {
    // remove with strong policy
    do {
      let hostObject = NSObject()
      let value = NSObject()
      hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? NSObject) === value
      hostObject.removeAssociatedObject(for: &AssociateKey.fooKey)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey)) == nil
    }

    // remove with mismatched policy
    do {
      let hostObject = NSObject()
      let value = NSObject()
      hostObject.setAssociatedObject(value, for: &AssociateKey.fooKey, associationPolicy: .strong)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey) as? NSObject) === value
      hostObject.removeAssociatedObject(for: &AssociateKey.fooKey, associationPolicy: .copy)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey)) == nil
    }
  }

  func testSetWeakAssociatedObject() {
    // when the object is retained
    do {
      let hostObject = NSObject()
      let value = NSObject() // strong reference

      // set
      hostObject.setWeakAssociatedObject(value, for: &AssociateKey.fooKey)
      let associatedValue: NSObject? = hostObject.getWeakAssociatedObject(for: &AssociateKey.fooKey)
      expect(associatedValue) === value

      // remove
      hostObject.removeAssociatedObject(for: &AssociateKey.fooKey)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey)) == nil
    }

    // when the object is retained
    do {
      let hostObject = NSObject()
      let value = NSObject() // strong reference

      // set
      hostObject.setWeakAssociatedObject(value, for: &AssociateKey.fooKey)
      let associatedValue: NSObject? = hostObject.getWeakAssociatedObject(for: &AssociateKey.fooKey)
      expect(associatedValue) === value

      // remove
      hostObject.setWeakAssociatedObject(nil as NSObject?, for: &AssociateKey.fooKey)
      expect(hostObject.getAssociatedObject(for: &AssociateKey.fooKey)) == nil
    }

    // when the object is not retained
    do {
      let hostObject = NSObject()
      var value: NSObject? = NSObject()
      hostObject.setWeakAssociatedObject(value, for: &AssociateKey.fooKey)
      value = nil // release the object
      let associatedValue: NSObject? = hostObject.getWeakAssociatedObject(for: &AssociateKey.fooKey)
      expect(associatedValue) == nil
    }
  }
}

//
//  AssociatedObject.swift
//
//  Created by Honghao Zhang on 2015-12-14.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/**
 A type that can be associated with objects.

 Example:
 ```
 // make a class support object association
 class FooClass: ObjectAssociatableType {
   ...
 }

 // usage
 private enum AssociateKey {
   static var fooKey: UInt8 = 0
 }

 fooObject.setAssociatedObject(someValue, for: &AssociateKey.fooKey)
 fooObject.getAssociatedObject(for: &AssociateKey.fooKey) as? SomeValueType
 ```
 */
public protocol ObjectAssociatableType {}

extension NSObject: ObjectAssociatableType {}

/// The association policy.
public enum AssociationPolicy {

  case weak

  case strong
  case strongAtomic

  /// copy: Objects that are small, atomic bits of data without any internal references to other objects.
  /// https://stackoverflow.com/questions/12877652/when-to-use-setter-attribute-copy-in-objective-c
  case copy
  case copyAtomic

  public var associationPolicy: objc_AssociationPolicy {
    switch self {
    case .weak:
      return .OBJC_ASSOCIATION_ASSIGN
    case .strong:
      return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    case .strongAtomic:
      return .OBJC_ASSOCIATION_RETAIN
    case .copy:
      return .OBJC_ASSOCIATION_COPY_NONATOMIC
    case .copyAtomic:
      return .OBJC_ASSOCIATION_COPY
    }
  }
}

public extension ObjectAssociatableType {

  /// Set an associated object for a key pointer.
  ///
  /// Example:
  /// ```
  /// private enum AssociateKey {
  ///   static var someKey: UInt8 = 0
  /// }
  ///
  /// hostObject.setAssociatedObject(someValue, for: &AssociateKey.someKey)
  /// hostObject.getAssociatedObject(for: &AssociateKey.someKey) as? SomeValueType
  /// ```
  ///
  /// - Parameters:
  ///   - object: An object to associate, use `nil` to clear.
  ///   - pointer: A key pointer.
  ///   - associationPolicy: The association policy. Default value is strong (non atomic).
  /// - Returns: The old associated object if have one.
  func setAssociatedObject(_ object: Any?, for pointer: UnsafeRawPointer, associationPolicy: AssociationPolicy = .strong) {
    switch associationPolicy {
    case .weak:
      // weak reference doesn't nil out if released
      // https://stackoverflow.com/questions/16569840/using-objc-setassociatedobject-with-weak-references
      ChouTi.assertFailure(".weak association policy is unsafe, use `setWeakAssociatedObject(_:for:)` & `getWeakAssociatedObject(_:for:)`")
    case .strong,
         .strongAtomic,
         .copy,
         .copyAtomic:
      objc_setAssociatedObject(self, pointer, object, associationPolicy.associationPolicy)
    }
  }

  /// Remove an associated object for a key pointer.
  /// - Parameters:
  ///   - pointer: A key pointer.
  ///   - associationPolicy: The association policy. Default value is strong (non atomic).
  func removeAssociatedObject(for pointer: UnsafeRawPointer, associationPolicy: AssociationPolicy = .strong) {
    setAssociatedObject(nil, for: pointer, associationPolicy: associationPolicy)
  }

  /// Get the associated object for a key pointer.
  ///
  /// Example:
  /// ```
  /// private enum AssociateKey {
  ///   static var someKey: UInt8 = 0
  /// }
  ///
  /// hostObject.setAssociatedObject(someValue, for: &AssociateKey.someKey)
  /// hostObject.getAssociatedObject(for: &AssociateKey.someKey) as? SomeValueType
  /// ```
  ///
  /// - Parameter pointer: A key pointer.
  /// - Returns: The associated object if have one.
  func getAssociatedObject(for pointer: UnsafeRawPointer) -> Any? {
    objc_getAssociatedObject(self, pointer)
  }

  /// Set a weakly retained associated object.
  ///
  /// Example:
  /// ```
  /// private enum AssociateKey {
  ///   static var someKey: UInt8 = 0
  /// }
  ///
  /// hostObject.setWeakAssociatedObject(weakObject, for: &AssociateKey.someKey)
  /// hostObject.getWeakAssociatedObject(for: &AssociateKey.someKey)
  /// ```
  ///
  /// - Parameters:
  ///   - object: An object to attach, use `nil` to clear.
  ///   - pointer: A key pointer.
  func setWeakAssociatedObject(_ object: (some Any)?, for pointer: UnsafeRawPointer) {
    if let object {
      let weakBox = WeakBox(object)
      objc_setAssociatedObject(self, pointer, weakBox, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    } else {
      objc_setAssociatedObject(self, pointer, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  /// Get the weakly retained associated object.
  ///
  /// Example:
  /// ```
  /// private enum AssociateKey {
  ///   static var someKey: UInt8 = 0
  /// }
  ///
  /// hostObject.setWeakAssociatedObject(weakObject, for: &AssociateKey.someKey)
  /// let associatedObject: ObjectType? = hostObject.getWeakAssociatedObject(for: &AssociateKey.someKey)
  /// ```
  ///
  /// - Parameter pointer: A key pointer.
  /// - Returns: Returns `nil` if there's no such association, or the object is released.
  func getWeakAssociatedObject<T>(for pointer: UnsafeRawPointer) -> T? {
    (objc_getAssociatedObject(self, pointer) as? WeakBox<T>)?.object
  }
}

// MARK: - Deprecated

// private enum AssociateKey {
//
//   /**
//    The key for `associatedObject`.
//
//    ```
//    // can print address like this:
//    let address = withUnsafePointer(to: &AssociateKey.associatedObjectKey) {
//        return $0
//    }
//    print(address) // print memory address of x
//    ```
//
//    Also tried with `static var associatedObjectKey: Void = ()` but it prints different memory address
//    But it seems like the `associatedObject` works with `Void` type, no idea why.
//
//    Read more:
//    https://stackoverflow.com/questions/42829907/why-unsaferawpointer-shows-different-result-when-function-signatures-differs-in
//    https://developer.apple.com/swift/blog/?id=6
//    */
//   static var associatedObjectKey: UInt8 = 0
// }
//
// public extension ObjectAssociatableType {
//
//   /// A convenient associated object.
//   var associatedObject: Any? {
//     get { objc_getAssociatedObject(self, &AssociateKey.associatedObjectKey) }
//     set { objc_setAssociatedObject(self, &AssociateKey.associatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
//   }
// }

// MARK: - Notes

// References:
// - [Associated Objects](http://nshipster.com/associated-objects/)
// - [objc_setAssociatedObject with nil to remove - is policy is ignored](http://stackoverflow.com/questions/19920591/objc-setassociatedobject-with-nil-to-remove-is-policy-checked)

// Inspiration:
// https://github.com/b9swift/AssociatedObject/blob/main/Sources/B9AssociatedObject/B9AssociatedObject.swift
// Can use `objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque())` as the key

// It sounds like there are some concerns that object association will be deprecated.
// https://forums.swift.org/t/objc-setassociatedobject-vs-swift/45188/4

//
//  Trigger.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/24/21.
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

/**
 A generic class that allows for decoupled communication between components through a fire-and-react mechanism.

 `Trigger` can be used to create a flexible event system where the firing component doesn't need to know about the reacting component(s).

 Example:
 ```swift
 // create a trigger
 let trigger = Trigger<Int>()

 // set a reaction to the trigger
 trigger.setReaction { [weak self] value in
   // react to the received value
 }

 // somewhere later, fire the trigger with a value
 trigger.fire(with: 2)
 ```
 */
public final class Trigger<Context>: Hashable {

  public typealias ReactionBlock = (_ context: Context) -> Void

  /// The trigger's reaction block. The block is called when `fire(with:)` is called.
  private var reactionBlock: ReactionBlock?

  /// An optional upstream binding. If this is non-nil, the binding will trigger `self` if the binding value changes.
  private var upstreamBinding: (any BindingType)?

  private var observation: BindingObservation?

  /// Initialize a trigger.
  public init() {}

  // MARK: - Public Methods

  /// Fire the trigger with a context.
  ///
  /// The reaction block is called synchronously.
  /// - Parameter context: The context to fire the trigger with.
  public func fire(with context: Context) {
    reactionBlock?(context)
  }

  /// Set a reaction block to the trigger.
  ///
  /// The reaction block is called synchronously.
  /// - Parameters:
  ///   - assertIfExists: If `true`, assert if the reaction block is already set.
  ///   - reaction: The reaction block to set.
  public func setReaction(assertIfExists: Bool = true, _ reaction: @escaping ReactionBlock) {
    if assertIfExists {
      ChouTi.assert(reactionBlock == nil, "Reaction block is already set")
    }
    reactionBlock = reaction
  }

  /// Check if the trigger has a reaction block.
  /// - Returns: `true` if the trigger has a reaction block, `false` otherwise.
  public func hasReaction() -> Bool {
    reactionBlock != nil
  }

  /// Remove the reaction block from the trigger.
  public func removeReaction() {
    reactionBlock = nil
  }

  // MARK: - Binding Support

  /// Subscribes the trigger to a binding. When the binding value changes, it fires the trigger.
  ///
  /// This method establishes a connection between a binding and the trigger. Whenever the binding's
  /// value changes, the trigger will fire with a context value derived from the binding's new value.
  ///
  /// - Important: The trigger (`self`) holds a strong reference to the binding.
  ///
  /// Example:
  /// ```swift
  /// let nameBinding = Binding("Alice")
  /// let trigger = Trigger<Int>()
  ///
  /// trigger.subscribe(to: nameBinding) { name in
  ///     return name.count // convert String to Int
  /// }
  ///
  /// trigger.setReaction { length in
  ///     print("Name length changed to: \(length)")
  /// }
  ///
  /// nameBinding.wrappedValue = "Bob" // Prints: "Name length changed to: 3"
  /// ```
  ///
  /// - Parameters:
  ///   - binding: The binding to subscribe to.
  ///   - map: A block that transforms the binding's value type to the trigger's context type.
  /// - Returns: The trigger self.
  @discardableResult
  public func subscribe<T>(to binding: some BindingType<T>, map: @escaping (T) -> Context) -> Self {
    if upstreamBinding != nil {
      // clear old binding
      observation.assert()?.cancel()
      observation = nil
    }

    upstreamBinding = binding

    observation = binding
      .observe { [weak self] value in
        self?.fire(with: map(value))
      }

    return self
  }

  /// Subscribes the trigger to a binding. When the binding value changes, it fires the trigger.
  ///
  /// This method establishes a connection between a binding and the trigger. Whenever the binding's
  /// value changes, the trigger will fire with the binding's new value.
  ///
  /// - Important: The trigger (`self`) holds a strong reference to the binding.
  ///
  /// - Parameters:
  ///   - binding: The binding to subscribe to.
  /// - Returns: The trigger self.
  @inlinable
  @inline(__always)
  @discardableResult
  public func subscribe(to binding: some BindingType<Context>) -> Self {
    subscribe(to: binding, map: { $0 })
  }

  /// Disconnect the trigger from its upstream binding.
  ///
  /// - Parameters:
  ///   - assertIfNotExists: If `true`, assert if the upstream binding exists.
  /// - Returns: The trigger self.
  @discardableResult
  public func disconnectFromBinding(assertIfNotExists: Bool = true) -> Self {
    if assertIfNotExists {
      ChouTi.assert(upstreamBinding != nil, "Trigger is not connected to a binding")
    }

    observation?.cancel()
    observation = nil
    upstreamBinding = nil
    return self
  }

  // MARK: - Hashable

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
  }

  // MARK: - Equatable

  public static func == (lhs: Trigger, rhs: Trigger) -> Bool {
    lhs === rhs
  }
}

public extension Trigger where Context == Void {

  /// Make a new trigger that subscribes to the binding.
  ///
  /// - Parameters:
  ///   - binding: The binding to subscribe to.
  convenience init(binding: some BindingType) {
    self.init()
    subscribe(to: binding)
  }

  /// Fires the trigger.
  @inlinable
  @inline(__always)
  func fire() {
    fire(with: ())
  }

  /// Sets a reaction block to the trigger.
  ///
  /// The reaction block is called synchronously.
  /// - Parameters:
  ///   - assertIfExists: If `true`, assert if the reaction block is already set.
  ///   - reaction: The reaction block to set.
  @inlinable
  @inline(__always)
  func setReaction(assertIfExists: Bool = true, _ reaction: @escaping () -> Void) {
    setReaction(assertIfExists: assertIfExists) { _ in
      reaction()
    }
  }

  /// Subscribes the trigger to a binding. When the binding value changes, it fires the trigger.
  ///
  /// This method establishes a connection between a binding and the trigger. Whenever the binding's
  /// value changes, the trigger will fire.
  ///
  /// - Important: The trigger (`self`) holds a strong reference to the binding.
  ///
  /// - Parameters:
  ///   - binding: The binding to subscribe to.
  @inlinable
  @inline(__always)
  @discardableResult
  func subscribe(to binding: some BindingType) -> Self {
    subscribe(to: binding, map: { _ in () })
  }
}

// Some attempts on making AnyTrigger:
/*
 public protocol TriggerType: an {

   associatedtype Context

   func fire(with context: Context)
   func setReaction(assertIfExists: Bool, _ reaction: @escaping (_ context: Context) -> Void)
   func hasReaction() -> Bool
   func removeReaction()
 }

 /// A type erased trigger.
 /// For example, you can store different types of triggers into one `AnyTrigger` array.
 public final class AnyTrigger: TriggerType {

   public typealias Context = Any

   private let reactionBlock: Trigger<Any>.ReactionBlock?

   init<T>(trigger: Trigger<T>) {

     // captures the block, not the trigger. So that the original trigger can be released.
     let originalReactionBlock = trigger.reactionBlock

     self.reactionBlock = { context in
       guard let context = context as? T else {
         ChouTi.assertFailure("bad context: \(context), expect the type be: \(T.self)")
         return
       }
       originalReactionBlock?(context)
     }

 //    if let upstreamBinding = trigger.upstreamBinding {
 //      self.connect(to: upstreamBinding)
 //    }
   }

   public func fire(with context: Context) {
     reactionBlock?(context)
   }

   public func setReaction(assertIfExists: Bool, _ reaction: @escaping (Context) -> Void) {

   }

   public func hasReaction() -> Bool {
     reactionBlock != nil
   }

   public func removeReaction() {
     let a = Trigger<Void>()
     let b = a as Trigger<Any>
     reactionBlock = nil
   }
 }

 //public extension Trigger where Context == Any {
 //
 //  convenience init<T>(trigger: Trigger<T>) {
 //    self.init()
 //
 //    // captures the block, not the trigger. So that the original trigger can be released.
 //    let originalReactionBlock = trigger.reactionBlock
 //
 //    self.reactionBlock = { context in
 //      guard let context = context as? T else {
 //        ChouTi.assertFailure("bad context: \(context), expect the type be: \(T.self)")
 //        return
 //      }
 //      originalReactionBlock?(context)
 //    }
 //
 //    if let upstreamBinding = trigger.upstreamBinding {
 ////      self.connect(to: upstreamBinding)
 //    }
 //  }
 //}

 */

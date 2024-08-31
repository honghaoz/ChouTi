//
//  BindingTests.swift
//  ChouTi
//
//  Created by Honghao Zhang on 5/27/22.
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

import Combine

import ChouTiTest

@testable import ChouTi

class BindingTests: XCTestCase {

  private var binding: Binding<Bool>!

  private let bindingObservationStorage = BindingObservationStorage()

  @Binding
  private var number: Int = 100

  private var cancellableSet: Set<AnyCancellable> = []

  override func tearDown() {
    binding = nil
    cancellableSet = []
    bindingObservationStorage.removeAll()
  }

  func test_basic_variable() {
    let observeExpectation = XCTestExpectation(description: "observe")
    let publisherExpectation = XCTestExpectation(description: "publisher")

    binding = Binding(false)

    var bindingCount = 0
    binding.observe { newValue in
      if bindingCount == 0 {
        expect(newValue) == true
      } else if bindingCount == 1 {
        expect(newValue) == false
        observeExpectation.fulfill()
      }
      bindingCount += 1
    }
    .store(in: self)

    var publisherCount = 0
    binding.publisher.dropFirst().sink { (newValue: Bool) in
      if publisherCount == 0 {
        expect(newValue) == true
      } else if publisherCount == 1 {
        expect(newValue) == false
        publisherExpectation.fulfill()
      }
      publisherCount += 1
    }.store(in: &cancellableSet)

    expect(binding.value) == false
    binding.toggle()
    expect(binding.value) == true

    binding.value = false
    expect(binding.value) == false

    wait(for: [observeExpectation, publisherExpectation], timeout: 0.5)
  }

  func test_basic_propertyWrapper() {
    let publisherExpectation = XCTestExpectation(description: "publisher")

    var publisherCount = 0
    $number.publisher.sink { newValue in
      if publisherCount == 0 {
        expect(newValue) == 100
      } else if publisherCount == 1 {
        expect(newValue) == 101
      } else if publisherCount == 2 {
        expect(newValue) == 102
        publisherExpectation.fulfill()
      }

      publisherCount += 1
    }.store(in: &cancellableSet)

    let observeExpectation = XCTestExpectation(description: "observe")
    var updateCount = 0
    let observation = $number.observe { newValue in
      if updateCount == 0 {
        expect(newValue) == 101
      } else if updateCount == 1 {
        expect(newValue) == 102
        observeExpectation.fulfill()
      }

      if updateCount == 2 {
        fail("block should be removed")
      }

      updateCount += 1
    }

    expect(number) == 100

    number += 1
    expect(number) == 101

    number += 1
    expect(number) == 102

    observation.cancel()
    number += 1

    wait(for: [publisherExpectation, observeExpectation], timeout: 0.5)
  }

  func test_basic_getterSetter() {
    var store: String = "initial"
    let binding = Binding<String>(get: { store }, set: { store = $0 })

    expect(binding.value) == "initial"

    var receivedValue: String?
    binding.observe { newValue in
      receivedValue = newValue
    }
    .store(in: self)

    binding.value = "new"
    expect(binding.value) == "new"
    expect(receivedValue) == "new"
  }

  func test_observe() {
    let observeExpectation1 = XCTestExpectation(description: "observe1")
    observeExpectation1.assertForOverFulfill = true
    $number.observe { newValue in
      expect(newValue) == 100
      observeExpectation1.fulfill()
    }
    .store(in: self)

    let observeExpectation2 = XCTestExpectation(description: "observe2")
    observeExpectation2.assertForOverFulfill = true
    let observation = $number.observe { newValue in
      expect(newValue) == 100
      observeExpectation2.fulfill()
    }
    _ = observation

    number = 100
    wait(for: [observeExpectation1, observeExpectation2], timeout: 0.5)
  }

  // MARK: - Immediate

  func test_observe_emitCurrentValue() {
    let observationExpectation = XCTestExpectation(description: "observe")
    observationExpectation.assertForOverFulfill = true
    $number
      .emitCurrentValue()
      .observe { newValue in
        expect(newValue) == 100
        observationExpectation.fulfill()
      }
      .store(in: self)
    wait(for: [observationExpectation], timeout: 0.05)
  }

  func test_observe_emitCurrentValue_cancel() {
    let observeExpectation = XCTestExpectation(description: "observe")
    observeExpectation.assertForOverFulfill = true

    $number
      .emitCurrentValue()
      .observe { newValue, _ in
        expect(newValue) == 100
        observeExpectation.fulfill()
      }
      .store(in: self)

    wait(for: [observeExpectation], timeout: 0.5)
  }

  func test_observe_emitCurrentValue_cancel_called() {
    let observeExpectation = XCTestExpectation(description: "observe")
    observeExpectation.assertForOverFulfill = true

    $number
      .emitCurrentValue()
      .observe { newValue, cancel in
        expect(newValue) == 100
        observeExpectation.fulfill()
        cancel()
      }
      .store(in: self)

    wait(for: [observeExpectation], timeout: 0.5)
  }

  func test_observe_emitCurrentValue_publisher() {
    let binding = Binding(true).emitCurrentValue()

    var receivedValue: Bool?
    binding.publisher
      .sink {
        receivedValue = $0
      }.store(in: &cancellableSet)

    expect(receivedValue) == true
  }

  func test_observe_emitCurrentValue_DeallocationNotifiable() {
    var binding: (some BindingType<Bool>)? = Binding(true).emitCurrentValue()

    var called: Bool?
    binding!.onDeallocate {
      called = true
    }

    binding = nil
    expect(called) == true
  }

  func test_observe_emitCurrentValue_DeallocationNotifiable_remove() {
    var binding: (some BindingType<Bool>)? = Binding(true).emitCurrentValue()

    var called: Bool?
    let token = binding!.onDeallocate {
      called = true
    }

    token.cancel()

    binding = nil
    expect(called) == nil
  }

  func test_observe_emitCurrentValue_store_observation() {
    var receivedValue: Int?
    var observation: BindingObservation? = $number
      .observe { newValue, _ in
        receivedValue = newValue
      }

    bindingObservationStorage.store(observation!)
    observation = nil

    number = 20
    expect(receivedValue) == 20

    bindingObservationStorage.removeAll()

    number = 33
    expect(receivedValue) == 20
  }

  func test_observe_emitCurrentValue_withMap() {
    let observationExpectation = XCTestExpectation(description: "observe")
    observationExpectation.assertForOverFulfill = true
    $number
      .emitCurrentValue()
      .map { value in
        value + 2
      }
      .observe { newValue in
        expect(newValue) == 102
        observationExpectation.fulfill()
      }
      .store(in: self)
    wait(for: [observationExpectation], timeout: 0.05)
  }

  func test_observe_cancelHandle() {
    let observeExpectation1 = XCTestExpectation(description: "observe1")
    observeExpectation1.assertForOverFulfill = true
    $number.observe { newValue, cancel in
      if newValue == 101 {
        observeExpectation1.fulfill()
        cancel()
      }
      if newValue == 102 {
        fail("should stop the update")
      }
    }
    .store(in: self)

    let observeExpectation2 = XCTestExpectation(description: "observe2")
    observeExpectation2.assertForOverFulfill = true
    $number.observe { newValue, stop in
      if newValue == 102 {
        observeExpectation2.fulfill()
      }
    }
    .store(in: self)

    let observeExpectation3 = XCTestExpectation(description: "observe3")
    observeExpectation3.assertForOverFulfill = true
    $number.observe { newValue, stop in
      if newValue == 103 {
        observeExpectation3.fulfill()
      }
    }
    .store(in: self)

    number = 100
    number = 101
    Waiter.wait(timeout: 0.005)
    number = 102
    Waiter.wait(timeout: 0.005)
    number = 103

    wait(for: [observeExpectation1, observeExpectation2, observeExpectation3], timeout: 0.1)
  }

  func test_binding_currentValueSubject() {
    let currentValueSubject = CurrentValueSubject<Int, Never>(0)

    let binding = currentValueSubject.binding
    binding.value += 1
    expect(currentValueSubject.value) == 1
  }

  func test_binding_expressible() {
    let voidBinding = Binding<Void>()
    _ = voidBinding

    let boolBinding: Binding<Bool> = true
    expect(boolBinding.value) == true

    let intBinding: Binding<Int> = 98
    expect(intBinding.value) == 98

    let doubleBinding: Binding<Double> = 98.89
    expect(doubleBinding.value) == 98.89

    let stringBinding: Binding<String> = "abc"
    expect(stringBinding.value) == "abc"

    let unicodeScalarBinding = Binding<String>(unicodeScalarLiteral: "\u{1F600}")
    expect(unicodeScalarBinding.value) == "😀"

    let extendedGraphemeClusterBinding = Binding<String>(extendedGraphemeClusterLiteral: "👨‍👩‍👧‍👦")
    expect(extendedGraphemeClusterBinding.value) == "👨‍👩‍👧‍👦"
  }

  // MARK: - Binding<Void>

  func test_binding_void() {
    let binding = Binding<Void>()

    var called: Bool = false
    binding.observe { _, _ in
      called = true
    }
    .store(in: self)

    expect(called) == false

    binding.send()
    expect(called) == true
  }

  // MARK: - Binding Storage

  func test_bindingStorage_reset() {
    let store = BindingStorage()

    weak var weakBinding: (any BindingType)? = Binding(1).store(in: store)
    expect(weakBinding) != nil
    weak var weakAnyBinding: (any BindingType)? = Binding(2).eraseToAnyBinding().store(in: store)
    expect(weakAnyBinding) != nil
    weak var weakMappedBinding: (any BindingType)? = Binding(1).map { "\($0)" }.store(in: store)
    expect(weakMappedBinding) != nil

    expect(store.contains(weakBinding!)) == true

    store.removeAll()
    expect(weakBinding) == nil
    expect(weakAnyBinding) == nil
    expect(weakMappedBinding) == nil
  }

  func test_bindingStorage_release() {
    var store: BindingStorage! = BindingStorage()

    weak var weakBinding: (any BindingType)? = Binding(1).store(in: store)
    expect(weakBinding) != nil
    weak var weakAnyBinding: (any BindingType)? = Binding(2).eraseToAnyBinding().store(in: store)
    expect(weakAnyBinding) != nil
    weak var weakMappedBinding: (any BindingType)? = Binding(1).map { "\($0)" }.store(in: store)
    expect(weakMappedBinding) != nil

    store = nil
    expect(weakBinding) == nil
    expect(weakAnyBinding) == nil
    expect(weakMappedBinding) == nil
  }

  func test_bindingStorage_remove() {
    let store = BindingStorage()

    weak var weakBinding: (any BindingType)? = Binding(1).store(in: store)
    expect(weakBinding) != nil
    weak var weakAnyBinding: (any BindingType)? = Binding(2).eraseToAnyBinding().store(in: store)
    expect(weakAnyBinding) != nil
    weak var weakMappedBinding: (any BindingType)? = Binding(1).map { "\($0)" }.store(in: store)
    expect(weakMappedBinding) != nil

    store.remove(weakBinding!)
    store.remove(weakAnyBinding!)
    store.remove(weakMappedBinding!)

    expect(weakBinding) == nil
    expect(weakAnyBinding) == nil
    expect(weakMappedBinding) == nil

    do {
      let binding = Binding(1).store(in: store)
      store.remove(binding)

      Assert.setTestAssertionFailureHandler { message, metadata, file, line, column in
        expect(message) == "remove non-existent binding: \(binding)"
      }
      store.remove(binding, assertIfNotExists: true)
      Assert.resetTestAssertionFailureHandler()
    }
  }

  func test_bindingStorage_store_with_key() {
    let store = BindingStorage()

    weak var weakBinding: (any BindingType)? = Binding(1).store(in: store)
    expect(weakBinding) != nil

    store.store(weakBinding!, for: "key")
    expect(store.binding(for: "key")) != nil

    expect(store.remove(for: "key")) != nil
    expect(store.remove(for: "key")) == nil
  }

  func test_BindingStorageProviding() {
    class SomeClass: BindingStorageProviding {
      init() {}
    }
    let someObject = SomeClass()
    expect(someObject.bindingStorage === someObject.bindingStorage) == true
  }

  // MARK: - Observation Storage

  func test_observationStorage_binding_store_external() {
    let binding = Binding(100)
    let storage = BindingObservationStorage()

    expect(storage.test_observations.count) == 0

    let observation = binding.observe { value, cancel in }
    observation.store(in: storage)

    expect(storage.contains(observation)) == true

    expect(storage.test_observations.count) == 1
    expect(storage.test_observations[ObjectIdentifier(observation)] === observation) == true
  }

  func test_observationStorage_binding_store_external_cancel_observation() {
    let binding = Binding(100)
    let storage = BindingObservationStorage()

    expect(storage.test_observations.count) == 0

    let observation = binding.observe { value, cancel in }
    observation.store(in: storage)

    expect(binding.test_registered_observations.count) == 1
    expect(storage.test_observations.count) == 1
    expect(storage.test_observations[ObjectIdentifier(observation)] === observation) == true

    observation.cancel()

    expect(binding.test_registered_observations.count) == 0
    expect(storage.test_observations.count) == 0
  }

  func test_observationStorage_binding_store_external_release_observation() {
    let binding = Binding(100)
    let storage = BindingObservationStorage()

    expect(storage.test_observations.count) == 0

    var observation: BindingObservation! = binding.observe { value, cancel in }
    observation.store(in: storage)
    weak var weakObservation: BindingObservation? = observation
    observation = nil

    expect(binding.test_registered_observations.count) == 1
    expect(storage.test_observations.count) == 1
    expect(storage.test_observations[ObjectIdentifier(weakObservation!)] === weakObservation!) == true

    storage.removeAll()
    expect(weakObservation) == nil

    expect(binding.test_registered_observations.count) == 0
    expect(storage.test_observations.count) == 0
  }

  func test_observationStorage_binding_store_external_anyBinding() {
    let binding = Binding(100).eraseToAnyBinding()
    let storage = BindingObservationStorage()

    expect(storage.test_observations.count) == 0

    let observation = binding.observe { value, cancel in }
    observation.store(in: storage)

    expect(storage.test_observations.count) == 1
    expect(storage.test_observations[ObjectIdentifier(observation)] === observation) == true
  }

  func test_observation_pause() {
    let binding = Binding(100)

    var received: Int?
    let ob = binding.observe {
      received = $0
    }

    expect(ob.isPaused) == false
    binding.value = 101
    expect(received) == 101

    ob.pause()
    expect(ob.isPaused) == true
    binding.value = 102
    expect(received) == 101

    ob.resume()
    expect(ob.isPaused) == false
    binding.value = 103
    expect(received) == 103
  }

  func test_replacing_observation_with_same_key() {
    let binding = Binding(100)

    let storage = BindingObservationStorage()

    var receivedValue1: Int?
    binding.observe {
      receivedValue1 = $0
    }.store(in: storage, for: "key1")

    binding.value = 101

    var receivedValue2: Int?
    binding.observe {
      receivedValue2 = $0
    }.store(in: storage, for: "key1")

    binding.value = 102

    expect(receivedValue1) == 101
    expect(receivedValue2) == 102
  }

  func test_BindingObservationStorageProviding() {
    class SomeClass: BindingObservationStorageProviding {
      init() {}
    }
    let someObject = SomeClass()
    expect(someObject.bindingObservationStorage) === someObject.bindingObservationStorage
  }

  // MARK: - DeallocationNotifiable

  func test_DeallocationNotifiable() {
    binding = Binding(false)

    var called: Bool?
    binding.onDeallocate {
      called = true
    }

    binding = nil
    expect(called) == true
  }

  func test_DeallocationNotifiable_remove() {
    binding = Binding(false)

    var called: Bool?
    let token = binding.onDeallocate {
      called = true
    }

    token.cancel()

    binding = nil
    expect(called) == nil
  }

  // MARK: - Subscribe

  func test_subscribe_deallocDownstream() {
    binding = Binding<Bool>(true)
    let sourceBinding = Binding<Int>(1)
    let mappedBinding = sourceBinding.map { $0 % 2 == 0 }
    let storage = BindingObservationStorage()
    binding.subscribe(to: mappedBinding).store(in: storage)

    sourceBinding.value = 3
    expect(binding.value) == false
    sourceBinding.value = 6
    expect(binding.value) == true

    expect(mappedBinding.test_registered_observations.count) == 1

    expect(binding.test_registered_observations.count) == 0

    binding = nil
    storage.removeAll()

    expect(mappedBinding.test_registered_observations.count) == 0
  }

  func test_subscribe_deallocSource() {
    binding = Binding<Bool>(true)
    let sourceBinding = Binding<Int>(1)
    var mappedBinding: (some BindingType<Bool>)? = sourceBinding.map { $0 % 2 == 0 }
    weak var mappedBindingWeak: (some BindingType<Bool>)? = mappedBinding
    let storage = BindingObservationStorage()
    binding.subscribe(to: mappedBinding!).store(in: storage)

    sourceBinding.value = 3
    expect(binding.value) == false
    sourceBinding.value = 6
    expect(binding.value) == true

    expect(mappedBinding!.test_registered_observations.count) == 1

    expect(binding.test_registered_observations.count) == 0

    mappedBinding = nil
    expect(mappedBindingWeak) != nil
    storage.removeAll()
    expect(mappedBindingWeak) == nil

    expect(binding.test_registered_observations.count) == 0

    binding = nil
    expect(mappedBindingWeak) == nil
  }

  // MARK: - Map

  func test_map() {
    binding = Binding(true)

    var mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    // update from upstream
    expect(binding.value) == true
    expect(mappedBinding!.value) == "yes"

    binding.value = false
    expect(binding.value) == false
    expect(mappedBinding!.value) == "yes" // mapped binding is not observed yet, still holds the old value

    _ = mappedBinding?.observe { _ in } // setup observation

    binding.value = false
    expect(mappedBinding!.value) == "no"

    expect(binding.test_registered_observations.count) == 1
    mappedBinding = nil
    expect(binding.test_registered_observations.count) == 0
  }

  func test_map_duplicateObservation() {
    let binding = Binding(true)
    let mappedBinding = binding.map { value in
      value ? "yes" : "no"
    }

    var callCount = 0
    let observation = mappedBinding.observe { _ in
      callCount += 1
    }
    observation.store(in: self)

    binding.value = false
    expect(mappedBinding.value) == "no"
    expect(callCount) == 1

    let observation2 = mappedBinding.observe { _ in
      callCount += 1
    }
    observation2.store(in: self)

    binding.value = true
    expect(mappedBinding.value) == "yes"
    expect(callCount) == 3
  }

  func test_map_viaAnyBinding() {
    binding = Binding(true)

    var mappedBinding: (some BindingType<String>)? = binding.eraseToAnyBinding().map { value in
      value ? "yes" : "no"
    }

    expect(binding.value) == true
    expect(mappedBinding!.value) == "yes"

    binding.value = false
    expect(binding.value) == false
    expect(mappedBinding!.value) == "yes" // mapped binding is not observed yet, still holds the old value

    _ = mappedBinding?.observe { _ in } // setup observation

    binding.value = false
    expect(mappedBinding!.value) == "no"

    expect(binding.test_registered_observations.count) == 1
    mappedBinding = nil
    expect(binding.test_registered_observations.count) == 0
  }

  func test_map_mappedBindingIsNotRetained() {
    binding = Binding(true)

    weak var weakBinding = binding.map { value in
      value ? "yes" : "no"
    }
    expect(weakBinding) == nil
  }

  func test_map_mappedBindingIsRetainedByObservation() {
    binding = Binding(true)

    var receivedValue: String?
    binding
      .map { value in
        value ? "yes" : "no"
      }
      .observe {
        receivedValue = $0
      }
      .store(in: self)

    expect(receivedValue) == nil
    binding.value = false
    expect(receivedValue) == "no"
  }

  func test_map_mappedBindingRetainsUpstreamBinding() {
    var upstreamStrong: Binding<Int>? = Binding<Int>(1)
    weak var upstreamWeak: Binding<Int>? = upstreamStrong

    // verify upstreamWeak is set to nil if the strong reference is gone
    expect(upstreamWeak) != nil

    upstreamStrong = nil
    expect(upstreamWeak) == nil

    // set up mapping
    upstreamStrong = Binding<Int>(1)
    upstreamWeak = upstreamStrong

    var mapped: (some BindingType<String>)? = upstreamWeak?.map(String.init)
    _ = mapped

    expect(upstreamWeak) != nil

    // release the strong reference doesn't release the weak upstream binding
    upstreamStrong = nil
    expect(upstreamWeak) != nil

    // release the mapped will release the upstream binding
    mapped = nil
    expect(upstreamWeak) == nil
  }

  func test_map_observe() {
    binding = Binding(true)

    let mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    var received: String?
    mappedBinding?.observe { value in
      received = value
    }.store(in: self)

    binding.value = false
    expect(received) == "no"

    binding.value = true
    expect(received) == "yes"
  }

  func test_map_observe_cancel() {
    binding = Binding(true)

    let mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    var received: String?
    mappedBinding?.observe { value, cancel in
      received = value
      cancel()
    }.store(in: self)

    binding.value = false
    expect(received) == "no"

    binding.value = true
    expect(received) == "no"
  }

  func test_map_publisher() {
    binding = Binding(true)

    let mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    var receivedValue: String?
    mappedBinding?.publisher
      .sink {
        receivedValue = $0
      }.store(in: &cancellableSet)

    expect(receivedValue) == "yes"
  }

  func test_map_publisher2() {
    var receivedValue: String?
    Binding(true)
      .map { value in
        value ? "yes" : "no"
      }
      .publisher
      .receive(on: .main, alwaysAsync: false)
      .sink {
        receivedValue = $0
      }
      .store(in: &cancellableSet)

    expect(receivedValue) == "yes"
  }

  func test_map_DeallocationNotifiable() {
    binding = Binding(true)

    var mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    var called: Bool?
    mappedBinding!.onDeallocate {
      called = true
    }

    mappedBinding = nil
    expect(called) == true
  }

  func test_map_DeallocationNotifiable_remove() {
    binding = Binding(true)

    var mappedBinding: (some BindingType<String>)? = binding.map { value in
      value ? "yes" : "no"
    }

    var called: Bool?
    let token = mappedBinding!.onDeallocate {
      called = true
    }

    token.cancel()

    mappedBinding = nil
    expect(called) == nil
  }

  // MARK: - removeDuplicates

  func test_removeDuplicates_explicitPredict() {
    let binding = Binding<Int>(1)
    let mapped = binding.removeDuplicates(by: { $0 == $1 })

    var setCount: Int = 0
    var setValue: Int?
    expect(setCount) == 0
    expect(setValue) == nil

    mapped.observe { value in
      setCount += 1
      setValue = value
    }.store(in: self)

    binding.value = 2
    expect(setCount) == 1
    expect(setValue) == 2

    binding.value = 2
    expect(setCount) == 1 // <-- this is not changed
    expect(setValue) == 2

    binding.value = 3
    expect(setCount) == 2 // <-- this is not changed
    expect(setValue) == 3
  }

  func test_removeDuplicates_implicitPredict() {
    let binding = Binding<Int>(1)
    let mapped = binding.removeDuplicates()

    var setCount: Int = 0
    var setValue: Int?
    expect(setCount) == 0
    expect(setValue) == nil

    mapped.observe { value in
      setCount += 1
      setValue = value
    }.store(in: self)

    binding.value = 2
    expect(setCount) == 1
    expect(setValue) == 2

    binding.value = 2
    expect(setCount) == 1 // <-- this is not changed
    expect(setValue) == 2
  }

  func test_removeDuplicates_releaseUpstream() {
    var upstream: Binding<Int>? = Binding<Int>(1)
    weak var upstreamWeak: Binding<Int>? = upstream

    expect(upstream!.test_registered_observations.count) == 0

    var mapped: (some BindingType<Int>)? = upstream!.removeDuplicates()
    _ = mapped?.observe { _ in } // setup observation

    expect(upstream!.test_registered_observations.count) == 1

    expect(mapped!.test_registered_observations.count) == 0

    upstream = nil
    expect(upstreamWeak) != nil

    mapped = nil
    expect(upstreamWeak) == nil
  }

  func test_removeDuplicates_releaseMapped() {
    let upstream: Binding<Int>? = Binding<Int>(1)

    expect(upstream!.test_registered_observations.count) == 0

    var mapped: (some BindingType<Int>)? = upstream!.removeDuplicates()
    _ = mapped?.observe { _ in } // setup observation

    expect(upstream!.test_registered_observations.count) == 1

    expect(mapped!.test_registered_observations.count) == 0

    mapped = nil

    expect(upstream!.test_registered_observations.count) == 0
  }

  func test_removeDuplicates_implicitPredict_readInitialValue() {
    let binding = Binding<Int>(1)
    let mapped = binding.removeDuplicates()

    expect(mapped.value) == 1
  }

  // MARK: - Connect

  func test_connect_dealloc_another() {
    binding = Binding(true)
    var another: Binding<String>! = Binding<String>("")

    let observation: BindingObservation? = binding.connect(
      to: another,
      mapTo: { value in
        value ? "yes" : "no"
      },
      setBack: { value in
        value == "test" ? true : false
      }
    )
    _ = observation

    // test initial values
    expect(binding.value) == true
    expect(another!.value) == "" // connect doesn't update value

    // update from self
    binding.value = false
    expect(another!.value) == "no"
    binding.value = true
    expect(another!.value) == "yes"

    // update from another
    another!.value = "random"
    expect(binding.value) == false

    another!.value = "test"
    expect(binding.value) == true

    expect(binding.test_registered_observations.count) == 1

    expect(another!.test_registered_observations.count) == 1

    another = nil

    expect(binding.test_registered_observations.count) == 1

    binding.value = false
  }

  func test_connect_dealloc_self() {
    binding = Binding(true)
    let another: Binding<String>! = Binding<String>("")

    let observation: BindingObservation? = binding.connect(
      to: another,
      mapTo: { value in
        value ? "yes" : "no"
      },
      setBack: { value in
        value == "test" ? true : false
      }
    )
    _ = observation

    // test initial values
    expect(binding.value) == true
    expect(another!.value) == "" // connect doesn't update value

    // update from self
    binding.value = false
    expect(another!.value) == "no"
    binding.value = true
    expect(another!.value) == "yes"

    // update from another
    another!.value = "random"
    expect(binding.value) == false

    another!.value = "test"
    expect(binding.value) == true

    expect(binding.test_registered_observations.count) == 1

    expect(another!.test_registered_observations.count) == 1

    binding = nil

    expect(another!.test_registered_observations.count) == 1

    another!.value = "aaa"
  }

  func test_connect_no_observation() {
    binding = Binding(true)
    let another: Binding<String>! = Binding<String>("")

    _ = binding.connect(
      to: another,
      mapTo: { value in
        value ? "yes" : "no"
      },
      setBack: { value in
        value == "test" ? true : false
      }
    )

    // test initial values
    expect(binding.value) == true
    expect(another!.value) == "" // connect doesn't update value

    // update from self
    binding.value = false
    expect(another!.value) == ""
    binding.value = true
    expect(another!.value) == ""

    // update from another
    another!.value = "random"
    expect(binding.value) == true

    another!.value = "test"
    expect(binding.value) == true
  }

  func test_connect_same_type_bindings() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")

    let observation = binding1.connect(to: binding2)
    _ = observation

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"

    // update from self
    binding1.value = "v1"
    expect(binding2.value) == "v1"

    // update from another
    binding2.value = "v2"
    expect(binding1.value) == "v2"
  }

  func test_connect_same_type_bindings_cancel() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")

    let observation = binding1.connect(to: binding2)
    observation.cancel()

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"

    // update from self
    binding1.value = "v1"
    expect(binding2.value) == "false"

    // update from another
    binding2.value = "v2"
    expect(binding1.value) == "v1"
  }

  func test_connect_same_type_bindings_store() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")

    binding1.connect(to: binding2).store(in: self)

    expect(binding1.test_registered_observations.count) == 1

    expect(binding2.test_registered_observations.count) == 1

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"

    // update from self
    binding1.value = "v1"
    expect(binding2.value) == "v1"

    // update from another
    binding2.value = "v2"
    expect(binding1.value) == "v2"
  }

  func test_connect_same_type_bindings_store_externally() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")

    let storage = BindingObservationStorage()

    binding1.connect(to: binding2).store(in: storage)

    expect(binding1.test_registered_observations.count) == 1

    expect(binding2.test_registered_observations.count) == 1

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"

    var binding1CallCount: Int = 0
    binding1.observe { _ in
      binding1CallCount += 1
    }
    .store(in: storage)

    var binding2CallCount: Int = 0
    binding2.observe { _ in
      binding2CallCount += 1
    }
    .store(in: storage)

    expect(binding1.test_registered_observations.count) == 2

    expect(binding2.test_registered_observations.count) == 2

    // update from self
    binding1.value = "v1"
    expect(binding2.value) == "v1"
    expect(binding1CallCount) == 1
    expect(binding2CallCount) == 1

    // update from another
    binding2.value = "v2"
    expect(binding1.value) == "v2"
    expect(binding1CallCount) == 2
    expect(binding2CallCount) == 2
  }

  func test_connect_two_pairs_of_bindings() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")
    let binding3 = Binding("none")

    binding1.connect(to: binding2).store(in: self)
    binding2.connect(to: binding3).store(in: self)

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"
    expect(binding3.value) == "none"

    // update from 1
    binding1.value = "v1"
    expect(binding2.value) == "v1"
    expect(binding3.value) == "v1"

    // update from 2
    binding2.value = "v2"
    expect(binding1.value) == "v2"
    expect(binding3.value) == "v2"

    // update from 3
    binding3.value = "33"
    expect(binding1.value) == "33"
    expect(binding2.value) == "33"
  }

  func test_connect_pause() {
    let binding1 = Binding("true")
    let binding2 = Binding("false")

    let storage = BindingObservationStorage()
    let observation = binding1.connect(to: binding2)

    storage.store(observation, for: "ob")

    // test initial values
    expect(binding1.value) == "true"
    expect(binding2.value) == "false"

    // update from 1
    binding1.value = "v1"
    expect(binding2.value) == "v1"

    // update from 2
    binding2.value = "v2"
    expect(binding1.value) == "v2"

    observation.pause()
    expect(observation.isPaused) == true

    binding1.value = "v3"
    expect(binding2.value) == "v2"

    binding2.value = "v4"
    expect(binding1.value) == "v3"

    observation.resume()
    expect(observation.isPaused) == false

    // update from 1
    binding1.value = "hey"
    expect(binding2.value) == "hey"

    // update from 2
    binding2.value = "yo"
    expect(binding1.value) == "yo"
  }

  // MARK: - Combine

  func test_combine() {
    let binding1 = Binding(true)
    let binding2 = Binding("123")
    var combinedBinding: (some BindingType<(Bool, String)>)? = binding1.combine(with: binding2)

    expect(binding1.test_registered_observations.count) == 1
    expect(binding2.test_registered_observations.count) == 1
    expect(combinedBinding?.test_registered_observations.count) == 0

    var receivedValue: (Bool, String)?
    combinedBinding?.observe { value in
      receivedValue = value
    }
    .store(in: self)

    expect(receivedValue) == nil

    expect(combinedBinding?.test_registered_observations.count) == 1

    combinedBinding?
      .emitCurrentValue()
      .observe { value in
        receivedValue = value
      }
      .store(in: self)
    expect(receivedValue?.0) == true
    expect(receivedValue?.1) == "123"

    binding1.value = false
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "123"

    binding2.value = "abc"
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "abc"

    combinedBinding = nil
    expect(binding1.test_registered_observations.count) == 1
    expect(binding2.test_registered_observations.count) == 1
  }

  func test_combine_releaseUpstream1() {
    binding = Binding(true)
    weak var weakBinding: Binding<Bool>? = binding
    let binding2 = Binding("123")
    var combinedBinding: (some BindingType<(Bool, String)>)? = binding.combine(with: binding2)
    weak var weakCombinedBinding: AnyObject? = combinedBinding

    expect(binding.test_registered_observations.count) == 1
    expect(binding2.test_registered_observations.count) == 1
    expect(combinedBinding?.test_registered_observations.count) == 0

    var receivedValue: (Bool, String)?
    let observation: BindingObservation! = combinedBinding?.observe { value in
      receivedValue = value
    }
    observation.store(in: self)

    expect(receivedValue) == nil

    // release upstream bindings doesn't affect the combined binding update
    binding = nil
    expect(weakBinding) != nil

    binding2.value = "789"
    expect(receivedValue?.0) == true
    expect(receivedValue?.1) == "789"

    combinedBinding = nil
    expect(weakCombinedBinding) != nil
    expect(weakBinding) != nil

    observation?.cancel()
    expect(weakCombinedBinding) == nil
    expect(weakBinding) == nil
  }

  func test_combine_releaseUpstream2() {
    binding = Binding(true)
    weak var weakBinding: Binding<Bool>? = binding
    var binding2: Binding<String>! = Binding("123")
    weak var weakBinding2: Binding<String>? = binding2
    var combinedBinding: (some BindingType<(Bool, String)>)? = binding.combine(with: binding2)

    expect(binding.test_registered_observations.count) == 1
    expect(binding2.test_registered_observations.count) == 1
    expect(combinedBinding?.test_registered_observations.count) == 0

    var receivedValue: (Bool, String)?
    let observation: BindingObservation! = combinedBinding?.observe { value in
      receivedValue = value
    }
    observation.store(in: self)

    expect(receivedValue) == nil

    // release upstream bindings doesn't affect the combined binding update
    binding2 = nil
    expect(weakBinding2) != nil

    binding.value = false
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "123"

    binding = nil
    expect(weakBinding) != nil
    expect(combinedBinding?.value.0) == false
    expect(combinedBinding?.value.1) == "123"

    combinedBinding = nil
    expect(weakBinding) != nil
    expect(weakBinding2) != nil

    observation?.cancel()
    expect(weakBinding) == nil
    expect(weakBinding2) == nil
  }

  func test_combine_publisher() {
    let binding1 = Binding(true)
    let binding2 = Binding("123")
    let combinedBinding: some BindingType<(Bool, String)> = binding1.combine(with: binding2)

    var receivedValue: (Bool, String)?
    combinedBinding.publisher.sink { value in
      receivedValue = value
    }.store(in: &cancellableSet)

    expect(receivedValue?.0) == true
    expect(receivedValue?.1) == "123"

    expect(combinedBinding.test_registered_observations.count) == 0

    binding1.value = false
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "123"

    binding2.value = "abc"
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "abc"
  }

  func test_combine_stop_handle() {
    let binding1 = Binding(true)
    let binding2 = Binding("123")
    let combinedBinding: (some BindingType<(Bool, String)>)? = binding1.combine(with: binding2)

    expect(binding1.test_registered_observations.count) == 1
    expect(binding2.test_registered_observations.count) == 1
    expect(combinedBinding?.test_registered_observations.count) == 0

    var receivedValue: (Bool, String)?
    combinedBinding?.observe { value, cancel in
      receivedValue = value
      cancel()
    }
    .store(in: self)

    expect(receivedValue) == nil

    expect(combinedBinding?.test_registered_observations.count) == 1

    binding1.value = false
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "123"

    expect(combinedBinding?.test_registered_observations.count) == 0

    binding2.value = "abc"
    expect(receivedValue?.0) == false
    expect(receivedValue?.1) == "123"
  }

  func test_combine_DeallocationNotifiable() {
    var combinedBinding: (some BindingType<(Bool, String)>)? = Binding(true).combine(with: Binding("123"))

    var called: Bool?
    combinedBinding!.onDeallocate {
      called = true
    }

    combinedBinding = nil
    expect(called) == true
  }

  func test_combine_DeallocationNotifiable_remove() {
    var combinedBinding: (some BindingType<(Bool, String)>)? = Binding(true).combine(with: Binding("123"))

    var called: Bool?
    let token = combinedBinding!.onDeallocate {
      called = true
    }

    token.cancel()

    combinedBinding = nil
    expect(called) == nil
  }

  func test_combine_two() {
    var u1: Binding<Int>! = Binding<Int>(1)
    var u2: Binding<Int>! = Binding<Int>(2)

    weak var u1Weak: Binding<Int>? = u1
    weak var u2Weak: Binding<Int>? = u2

    var combined: AnyBinding<(Int, Int)>?

    var updatedValue: (Int, Int)?
    combined = Bindings.combine(u1, u2).eraseToAnyBinding()
    let observation = combined?.observe { value in
      updatedValue = value
    }
    expect(updatedValue) == nil

    u1.value = 10
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 2

    // release strong references, should not release
    u1 = nil
    u2 = nil

    expect(u1Weak) != nil
    expect(u2Weak) != nil

    u2Weak?.value = 20
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 20

    combined = nil
    expect(u1Weak) != nil
    expect(u2Weak) != nil

    observation?.cancel()
    expect(u1Weak) == nil
    expect(u2Weak) == nil
  }

  func test_combine_three() {
    var u1: Binding<Int>! = Binding<Int>(1)
    var u2: Binding<Int>! = Binding<Int>(2)
    var u3: Binding<Int>! = Binding<Int>(3)

    weak var u1Weak: Binding<Int>? = u1
    weak var u2Weak: Binding<Int>? = u2
    weak var u3Weak: Binding<Int>? = u3

    var combined: AnyBinding<(Int, Int, Int)>?

    var updatedValue: (Int, Int, Int)?
    combined = Bindings.combine(u1, u2, u3).eraseToAnyBinding()
    let observation = combined?.observe { value in
      updatedValue = value
    }
    expect(updatedValue) == nil

    u1.value = 10
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 2
    expect(updatedValue?.2) == 3

    // release strong references, should not release
    u1 = nil
    u2 = nil
    u3 = nil

    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil

    u2Weak?.value = 20
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 20
    expect(updatedValue?.2) == 3

    combined = nil
    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil

    observation?.cancel()
    expect(u1Weak) == nil
    expect(u2Weak) == nil
    expect(u3Weak) == nil
  }

  func test_combine_four() {
    var u1: Binding<Int>! = Binding<Int>(1)
    var u2: Binding<Int>! = Binding<Int>(2)
    var u3: Binding<Int>! = Binding<Int>(3)
    var u4: Binding<Int>! = Binding<Int>(4)

    weak var u1Weak: Binding<Int>? = u1
    weak var u2Weak: Binding<Int>? = u2
    weak var u3Weak: Binding<Int>? = u3
    weak var u4Weak: Binding<Int>? = u4

    var combined: AnyBinding<(Int, Int, Int, Int)>?

    var updatedValue: (Int, Int, Int, Int)?
    combined = Bindings.combine(u1, u2, u3, u4).eraseToAnyBinding()
    let observation = combined?.observe { value in
      updatedValue = value
    }
    expect(updatedValue) == nil

    u1.value = 10
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 2
    expect(updatedValue?.2) == 3
    expect(updatedValue?.3) == 4

    // release strong references, should not release
    u1 = nil
    u2 = nil
    u3 = nil
    u4 = nil

    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil
    expect(u4Weak) != nil

    u2Weak?.value = 20
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 20
    expect(updatedValue?.2) == 3
    expect(updatedValue?.3) == 4

    combined = nil
    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil
    expect(u4Weak) != nil

    observation?.cancel()
    expect(u1Weak) == nil
    expect(u2Weak) == nil
    expect(u3Weak) == nil
    expect(u4Weak) == nil
  }

  func test_combine_five() {
    var u1: Binding<Int>! = Binding<Int>(1)
    var u2: Binding<Int>! = Binding<Int>(2)
    var u3: Binding<Int>! = Binding<Int>(3)
    var u4: Binding<Int>! = Binding<Int>(4)
    var u5: Binding<Int>! = Binding<Int>(5)

    weak var u1Weak: Binding<Int>? = u1
    weak var u2Weak: Binding<Int>? = u2
    weak var u3Weak: Binding<Int>? = u3
    weak var u4Weak: Binding<Int>? = u4
    weak var u5Weak: Binding<Int>? = u5

    var combined: AnyBinding<(Int, Int, Int, Int, Int)>?

    var updatedValue: (Int, Int, Int, Int, Int)?
    combined = Bindings.combine(u1, u2, u3, u4, u5).eraseToAnyBinding()
    let observation = combined?.observe { value in
      updatedValue = value
    }
    expect(updatedValue) == nil

    u1.value = 10
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 2
    expect(updatedValue?.2) == 3
    expect(updatedValue?.3) == 4
    expect(updatedValue?.4) == 5

    // release strong references, should not release
    u1 = nil
    u2 = nil
    u3 = nil
    u4 = nil
    u5 = nil

    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil
    expect(u4Weak) != nil
    expect(u5Weak) != nil

    u2Weak?.value = 20
    expect(updatedValue?.0) == 10
    expect(updatedValue?.1) == 20
    expect(updatedValue?.2) == 3
    expect(updatedValue?.3) == 4
    expect(updatedValue?.4) == 5

    combined = nil
    expect(u1Weak) != nil
    expect(u2Weak) != nil
    expect(u3Weak) != nil
    expect(u4Weak) != nil
    expect(u5Weak) != nil

    observation?.cancel()
    expect(u1Weak) == nil
    expect(u2Weak) == nil
    expect(u3Weak) == nil
    expect(u4Weak) == nil
    expect(u5Weak) == nil
  }

  // MARK: - Pause

  func test_pause() {
    expect($number.isPaused) == false

    var shouldAccept = false
    $number.observe { newValue in
      if !shouldAccept {
        fail("should pause")
      }
    }
    .store(in: self)

    $number.pause()
    expect($number.isPaused) == true
    number = 10

    shouldAccept = true
    $number.resume()
    expect($number.isPaused) == false
    number = 20
  }

  // MARK: - Static Binding

  // MARK: - AnyBinding

  func test_anyBinding() {
    let binding = Binding("1")
    let anyBinding = binding.eraseToAnyBinding()

    // value
    expect(anyBinding.value) == "1"

    // publisher
    var receivedValue: String?
    anyBinding.publisher
      .sink {
        receivedValue = $0
      }
      .store(in: &cancellableSet)

    binding.value = "2"
    expect(receivedValue) == "2"
    expect(anyBinding.value) == "2"

    cancellableSet.removeAll()

    // observe
    var observation: BindingObservation! = anyBinding.observe {
      receivedValue = $0
    }
    _ = observation

    binding.value = "3"
    expect(receivedValue) == "3"
    expect(anyBinding.value) == "3"

    observation = nil

    // observe 2
    observation = anyBinding.observe { value, cancel in
      receivedValue = value
    }

    binding.value = "4"
    expect(receivedValue) == "4"
    expect(anyBinding.value) == "4"

    observation = nil

    // store
    anyBinding
      .observe {
        receivedValue = $0
      }
      .store(in: self)

    binding.value = "5"
    expect(receivedValue) == "5"
    expect(anyBinding.value) == "5"
  }

  func test_anyBinding_DeallocationNotifiable() {
    var anyBinding: AnyBinding! = Binding("1").eraseToAnyBinding()

    var called: Bool?
    anyBinding.onDeallocate {
      called = true
    }

    anyBinding = nil
    expect(called) == true
  }

  func test_anyBinding_DeallocationNotifiable_remove() {
    var anyBinding: AnyBinding! = Binding("1").eraseToAnyBinding()

    var called: Bool?
    let token = anyBinding.onDeallocate {
      called = true
    }

    token.cancel()

    anyBinding = nil
    expect(called) == nil
  }

  // MARK: - Observations

  func test_observation_storage_cancel_to_release() {
    let binding = Binding("1")
    var observation: BindingObservation! = binding.observe { _ in }
    weak var weakObservation: BindingObservation! = observation

    let storage = BindingObservationStorage()
    storage.store(observation)

    expect(binding.test_registered_observations.count) == 1
    expect(storage.test_observations.count) == 1

    observation = nil
    expect(weakObservation) != nil

    weakObservation.cancel()
    expect(weakObservation) == nil
    expect(binding.test_registered_observations.count) == 0
    expect(storage.test_observations.count) == 0
  }

  func test_observation_binding_cancel_to_release() {
    let binding = Binding("1")
    var observation: BindingObservation! = binding.observe { _ in }
    weak var weakObservation: BindingObservation! = observation

    bindingObservationStorage.store(observation)

    expect(binding.test_registered_observations.count) == 1

    observation = nil
    expect(weakObservation) != nil

    weakObservation.cancel()
    expect(weakObservation) == nil

    expect(binding.test_registered_observations.count) == 0
  }

  func test_observation_order() {
    let binding = Binding("1")

    var orders: [Int] = []
    binding.observe { value in
      orders.append(1)
    }.store(in: self)

    binding.observe { value in
      orders.append(2)
    }.store(in: self)

    binding.observe { value in
      orders.append(3)
    }.store(in: self)

    binding.value = "2"

    expect(orders) == [1, 2, 3]
  }

  func test_binding_observation_store_with_key() {
    let binding = Binding("1")
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_anyBinding_observation_store_with_key() {
    let binding = Binding("1").eraseToAnyBinding()
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_combinedBinding_observation_store_with_key() {
    let binding = Binding("1").combine(with: Binding(2))
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_immediateBinding_observation_store_with_key() {
    let binding = Binding("1").emitCurrentValue()
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_mappedBinding_observation_store_with_key() {
    let binding = Binding("1").map { _ in 0 }
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_staticBinding_observation_store_with_key() {
    let binding = StaticBinding("1")
    let storage = BindingObservationStorage()

    let observation = binding.observe { _ in }
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil

    expect(storage.remove(for: "key") === observation) == true
    expect(storage.observation(for: "key")) == nil
  }

  func test_connectBinding_observation_store_with_key() {
    let binding1 = Binding("1")
    let binding2 = Binding("2")
    let storage = BindingObservationStorage()

    let observation = binding1.connect(to: binding2)
    observation.store(in: storage, for: "key")
    expect(storage.observation(for: "key")) != nil
    expect(storage.observation(for: "key")) != nil

    storage.remove(for: "key")
    expect(storage.observation(for: "key")) == nil
    storage.remove(for: "key")
    expect(storage.observation(for: "key")) == nil
  }

  func test_NSObject_observation_storage() {
    var object: NSObject? = NSObject()

    let binding = Binding("1")
    var receivedValue: String?
    binding
      .observe {
        receivedValue = $0
      }
      .store(in: object!.bindingObservationStorage)

    expect(object!.bindingObservationStorage) === object!.bindingObservationStorage
    expect(object!.bindingObservationStorage.test_observations.count) == 1

    binding.value = "2"
    expect(receivedValue) == "2"

    object = nil
    binding.value = "3"
    expect(receivedValue) == "2"
  }

  // MARK: - Scheduler

  func test_receiveOnMain_noAsync() {
    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: .main)
      .observe { value in
        expect(DispatchQueue.isOnQueue(.main)) == true
        received = value
      }
      .store(in: self)

    binding.value = 2
    expect(received) == 2
  }

  func test_receiveOnMain_async() {
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: .main, alwayAsync: true)
      .observe { value in
        expect(DispatchQueue.isOnQueue(.main)) == true
        received = value

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    binding.value = 2
    expect(received) == nil

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnQueue_fromMain() {
    let queue = DispatchQueue.make(label: "test")
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    binding
      .receive(on: queue)
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    binding.value = 2

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnQueue_fromQueue_noAsync() {
    let queue = DispatchQueue.make(label: "test")
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: queue)
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true
        received = value

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    queue.sync {
      binding.value = 2
    }
    expect(received) == 2

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnQueue_fromQueue_async() {
    let queue = DispatchQueue.make(label: "test")
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: queue, alwayAsync: true)
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true
        received = value

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    queue.sync {
      binding.value = 2
    }
    expect(received) == nil

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnMain_delay() {
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    let delayedBinding = binding
      .delay(0.01, receiveOn: .main)
    expect(delayedBinding.value) == 1

    delayedBinding
      .observe { value in
        expect(DispatchQueue.isOnQueue(.main)) == true
        received = value

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    binding.value = 2
    expect(received) == nil

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnMain_delay_0() {
    let binding = Binding(1)
    var received: Int?
    binding
      .delay(0, receiveOn: .main)
      .observe { value in
        expect(DispatchQueue.isOnQueue(.main)) == true
        received = value
      }
      .store(in: self)

    binding.value = 2
    expect(received) == 2
  }

  func test_delay_release() {
    let binding = Binding(1)
    var received: Int?
    var delayedBinding: (any BindingType<Int>)? = binding
      .delay(0.1, receiveOn: .main)

    var observation: BindingObservation? = delayedBinding?.observe { value in
      received = value
    }
    _ = observation

    binding.value = 2
    expect(received) == nil

    // release delayedBinding
    delayedBinding = nil
    observation = nil

    Waiter.wait(timeout: 0.2)
    expect(received) == nil // not updated
  }

  func test_receiveOn_twice() {
    let queue = DispatchQueue.make(label: "test")
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: queue)
      .receive(on: .main)
      .observe { value in
        expect(DispatchQueue.isOnQueue(.main)) == true
        received = value

        if value == 2 {
          expectation.fulfill()
        } else {
          fail("incorrect value")
        }
      }
      .store(in: self)

    binding.value = 2
    expect(received) == nil

    wait(for: [expectation], timeout: 0.5)
  }

  func test_receiveOnQueue_publisher() {
    let queue = DispatchQueue.make(label: "test")
    let expectation = XCTestExpectation(description: "received")

    let binding = Binding(1)
    var received: Int?
    binding
      .receive(on: queue)
      .store(in: binding.bindingStorage)
      .publisher
      .dropFirst()
      .sink {
        expect(DispatchQueue.isOnQueue(queue)) == true
        received = $0
        expect($0) == 2
        expectation.fulfill()
      }
      .store(in: &cancellableSet)

    binding.value = 2
    expect(received) == nil

    wait(for: [expectation], timeout: 0.2)
  }

  // MARK: - Debounce

  func test_leadingDebounce() {
    let binding = Binding(0)

    var count: Int = 0
    var received: Int?
    let newBinding = binding
      .leadingDebounce(for: 0.1)
    expect(newBinding.value) == 0

    newBinding
      .observe { value in
        count += 1
        received = value
      }
      .store(in: self)

    expect(received) == nil
    expect(count) == 0

    binding.value = 1
    expect(received) == 1
    expect(count) == 1

    binding.value = 2
    expect(received) == 1
    expect(count) == 1

    binding.value = 3
    expect(received) == 1
    expect(count) == 1

    Waiter.wait(timeout: 0.15)
    binding.value = 4
    expect(received) == 4
    expect(count) == 2
  }

  func test_trailingDebounce() {
    let queue = DispatchQueue.make(label: "test")
    let binding = Binding(0)

    var count: Int = 0
    var received: Int?
    let newBinding = binding
      .trailingDebounce(for: 0.1, queue: queue)
    expect(newBinding.value) == 0

    newBinding
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true
        count += 1
        received = value
      }
      .store(in: self)

    expect(received) == nil
    expect(count) == 0

    binding.value = 1
    expect(received) == nil
    expect(count) == 0

    binding.value = 2
    expect(received) == nil
    expect(count) == 0

    Waiter.wait(timeout: 0.3)
    expect(received) == 2
    expect(count) == 1
  }

  // MARK: - Throttle

  func test_throttle_latest() {
    let queue = DispatchQueue.make(label: "test")
    let binding = Binding(0)

    var count: Int = 0
    var received: Int?
    let newBinding = binding
      .throttle(for: 0.2, latest: true, queue: queue)
    expect(newBinding.value) == 0

    newBinding
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true
        count += 1
        received = value
      }
      .store(in: self)

    expect(received) == nil
    expect(count) == 0

    binding.value = 1
    expect(received) == nil
    expect(count) == 0

    binding.value = 2
    expect(received) == nil
    expect(count) == 0

    Waiter.wait(timeout: 0.4)
    expect(received) == 2
    expect(count) == 1

    binding.value = 3
    expect(received) == 2
    expect(count) == 1
  }

  func test_throttle_first() {
    let queue = DispatchQueue.make(label: "test")
    let binding = Binding(0)

    var count: Int = 0
    var received: Int?
    binding
      .throttle(for: 0.2, latest: false, queue: queue)
      .observe { value in
        expect(DispatchQueue.isOnQueue(queue)) == true
        count += 1
        received = value
      }
      .store(in: self)

    expect(received) == nil
    expect(count) == 0

    binding.value = 1
    expect(received) == nil
    expect(count) == 0

    binding.value = 2
    expect(received) == nil
    expect(count) == 0

    Waiter.wait(timeout: 0.4)
    expect(received) == 1
    expect(count) == 1

    binding.value = 3
    expect(received) == 1
    expect(count) == 1
  }

  func test_bindingWithGetter_whenBackingStoreChanged_publisherNotEmit() {
    var backingNumber: Int = 0
    let binding = Binding<Int>(get: { backingNumber }, set: { backingNumber = $0 })

    var receivedNumbersViaObserve: [Int] = []
    let observation = binding.observe {
      receivedNumbersViaObserve.append($0)
    }
    _ = observation

    var receivedNumbersViaPublisher: [Int] = []
    let subscription = binding.publisher.sink {
      receivedNumbersViaPublisher.append($0)
    }
    _ = subscription

    binding.value = 1
    expect(backingNumber) == 1
    expect(receivedNumbersViaObserve) == [1]
    expect(receivedNumbersViaPublisher) == [0, 1]

    binding.value = 2
    expect(backingNumber) == 2
    expect(receivedNumbersViaObserve) == [1, 2]
    expect(receivedNumbersViaPublisher) == [0, 1, 2]

    backingNumber = 10
    expect(binding.value) == 10

    expect(receivedNumbersViaObserve) == [1, 2] // no value updates
    expect(receivedNumbersViaPublisher) == [0, 1, 2] // no value updates
  }

  // MARK: - Hashable

  func test_binding_hashable() {
    // given
    let binding1 = Binding(1)
    let binding2 = Binding(2)
    let binding3 = Binding(3)

    let set: Set<Binding<Int>> = [binding1, binding2, binding3]
    expect(set.count) == 3
    expect(set.contains(binding1)) == true
    expect(set.contains(binding2)) == true
    expect(set.contains(binding3)) == true

    expect(binding1.hashValue) != binding2.hashValue
    expect(binding1.hashValue) != binding3.hashValue
    expect(binding2.hashValue) != binding3.hashValue

    expect(binding1.hashValue) == binding1.hashValue
    expect(binding2.hashValue) == binding2.hashValue
    expect(binding3.hashValue) == binding3.hashValue
  }
}

extension BindingType {

  var test_registered_observations: [ObjectIdentifier: AnyObject] {
    DynamicLookup(self).keyPath("implementation.registeredObservations.dictionary") ?? [:]
  }
}

extension BindingObservationStorage {

  var test_observations: [ObjectIdentifier: BindingObservation] {
    DynamicLookup(self).observations ?? [:]
  }
}

extension PrivateBindingObservation {

  var test_upstreamBinding: AnyObject? {
    DynamicLookup(self).upstreamBinding
  }

  var test_containingStorage: [ObjectIdentifier: WeakBox<BindingObservationStorage>] {
    DynamicLookup(self).containingStorage ?? [:]
  }
}

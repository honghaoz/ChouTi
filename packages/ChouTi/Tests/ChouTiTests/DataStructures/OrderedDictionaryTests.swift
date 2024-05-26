//
//  OrderedDictionaryTests.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import XCTest
import ChouTiTest

@testable import ChouTi

class OrderedDictionaryTests: XCTestCase {

  private var dict: OrderedDictionary<String, Int>!

  override func setUp() {
    super.setUp()

    dict = [:]
  }

  override func tearDown() {
    super.tearDown()

    dict = nil
  }

  func testInit() {
    dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
    XCTAssertEqual(dict.count, 3)
    XCTAssertEqual(dict.keys, ["a", "b", "c"])
    XCTAssertEqual(dict.values, [1, 2, 3])

    dict = OrderedDictionary<String, Int>()
    expect(dict.isEmpty) == true
    expect(dict.keys.isEmpty) == true
    expect(dict.values.isEmpty) == true
  }

  func testBadInit() {
    do {
      let dict = OrderedDictionary<String, Int>(keys: ["a", "b"], values: [1, 2, 3])
      expect(dict) == nil
    }

    do {
      let dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2])
      expect(dict) == nil
    }

    do {
      let dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c", "c"], values: [1, 2, 3, 4])
      expect(dict) == nil
    }
  }

  func testInitLiteral() {
    dict = [
      "a": 1,
      "b": 2,
      "c": 3,
    ]
    XCTAssertEqual(dict.count, 3)
    XCTAssertEqual(dict.keys, ["a", "b", "c"])
    XCTAssertEqual(dict.values, [1, 2, 3])
  }

  func testSubscript() {
    dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
    // test get
    XCTAssertEqual(dict["a"], 1)

    // test insert new key
    dict["e"] = 5
    XCTAssertEqual(dict["e"], 5)
    XCTAssertEqual(dict.keys, ["a", "b", "c", "e"])

    // test insert existing key
    dict["b"] = 12
    XCTAssertEqual(dict["b"], 12)
    XCTAssertEqual(dict.keys, ["a", "b", "c", "e"])
  }

  func testAppend() {
    dict.append(value: 1, forKey: "a")
    XCTAssertEqual(dict["a"], 1)
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.keys, ["a"])
    XCTAssertEqual(dict.values, [1])

    dict.append(value: 2, forKey: "b")
    XCTAssertEqual(dict["b"], 2)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.keys, ["a", "b"])
    XCTAssertEqual(dict.values, [1, 2])

    dict.append(value: 3, forKey: "c")
    XCTAssertEqual(dict["c"], 3)
    XCTAssertEqual(dict.count, 3)
    XCTAssertEqual(dict.keys, ["a", "b", "c"])
    XCTAssertEqual(dict.values, [1, 2, 3])
  }

  func testPopLast() {
    dict.append(value: 1, forKey: "a")
    dict.append(value: 2, forKey: "b")
    dict.append(value: 3, forKey: "c")

    let removed = dict.popLast()
    XCTAssertEqual(removed?.0, "c")
    XCTAssertEqual(removed?.1, 3)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.keys, ["a", "b"])
    XCTAssertEqual(dict.values, [1, 2])

    let removed2 = dict.popLast()
    XCTAssertEqual(removed2?.0, "b")
    XCTAssertEqual(removed2?.1, 2)
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.keys, ["a"])
    XCTAssertEqual(dict.values, [1])

    let removed3 = dict.popLast()
    XCTAssertEqual(removed3?.0, "a")
    XCTAssertEqual(removed3?.1, 1)
    XCTAssertEqual(dict.count, 0)
    XCTAssertEqual(dict.keys, [])
    XCTAssertEqual(dict.values, [])

    let removed4 = dict.popLast()
    XCTAssertNil(removed4)
  }

  func testHasKey() {
    dict["a"] = 1
    XCTAssertTrue(dict.hasKey("a"))
    XCTAssertFalse(dict.hasKey("b"))
  }

  func testHasNoKey() {
    dict.append(value: 1, forKey: "a")
    XCTAssertFalse(dict.hasNoKey("a"))
    XCTAssertTrue(dict.hasNoKey("b"))
  }

  func testReserveCapacity() {
    dict.removeAll(keepingCapacity: false)
    dict.reserveCapacity(10)
    XCTAssertGreaterThanOrEqual(dict.capacity, 10, "dictionary should have at least capacity of 10")
  }

  func testBasicOperations() {
    XCTAssertNil(dict["none"])
    XCTAssertNil(dict.firstValue)
    XCTAssertNil(dict.lastValue)

    dict["apple"] = 1
    XCTAssertEqual(dict["apple"], 1)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.firstValue, 1)
    XCTAssertEqual(dict.lastValue, 1)

    dict["apple"] = 11
    XCTAssertEqual(dict["apple"], 11)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 11)
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.firstValue, 11)
    XCTAssertEqual(dict.lastValue, 11)

    dict["banana"] = 2
    XCTAssertEqual(dict["banana"], 2)
    XCTAssertEqual(dict[1].0, "banana")
    XCTAssertEqual(dict[1].1, 2)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.firstValue, 11)
    XCTAssertEqual(dict.lastValue, 2)

    XCTAssertEqual(dict.keys, ["apple", "banana"])
    XCTAssertEqual(dict.values, [11, 2])

    dict.removeValue(forKey: "apple")
    XCTAssertNil(dict["apple"])
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.firstValue, 2)
    XCTAssertEqual(dict.lastValue, 2)

    dict["orange"] = 123
    XCTAssertEqual(dict["orange"], 123)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.firstValue, 2)
    XCTAssertEqual(dict.lastValue, 123)

    dict["orange"] = nil
    XCTAssertNil(dict["orange"])
    XCTAssertEqual(dict.count, 1)
    XCTAssertEqual(dict.firstValue, 2)
    XCTAssertEqual(dict.lastValue, 2)

    dict.removeAll()
    XCTAssertEqual(dict.count, 0)
    XCTAssertNil(dict.firstValue)
    XCTAssertNil(dict.lastValue)
  }

  func testInsertionAtIndex() {
    dict["apple"] = 1
    XCTAssertEqual(dict["apple"], 1)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict.count, 1)

    dict.insert(value: 2, forKey: "banana", atIndex: 1)
    XCTAssertEqual(dict["banana"], 2)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict[1].0, "banana")
    XCTAssertEqual(dict[1].1, 2)
    XCTAssertEqual(dict.count, 2)

    dict.insert(value: 3, forKey: "orange", atIndex: 1)
    XCTAssertEqual(dict["orange"], 3)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict[1].0, "orange")
    XCTAssertEqual(dict[1].1, 3)
    XCTAssertEqual(dict[2].0, "banana")
    XCTAssertEqual(dict[2].1, 2)
    XCTAssertEqual(dict.count, 3)

    var newDict = dict! // swiftlint:disable:this force_unwrapping
    newDict.insert(value: 4, forKey: "apple", atIndex: 2)
    XCTAssertEqual(newDict["apple"], 4)
    XCTAssertEqual(newDict[0].0, "orange")
    XCTAssertEqual(newDict[0].1, 3)
    XCTAssertEqual(newDict[1].0, "banana")
    XCTAssertEqual(newDict[1].1, 2)
    XCTAssertEqual(newDict[2].0, "apple")
    XCTAssertEqual(newDict[2].1, 4)
    XCTAssertEqual(newDict.count, 3)

    newDict = dict! // swiftlint:disable:this force_unwrapping
    newDict.insert(value: 4, forKey: "apple", atIndex: 3)
    XCTAssertEqual(newDict["apple"], 4)
    XCTAssertEqual(newDict[0].0, "orange")
    XCTAssertEqual(newDict[0].1, 3)
    XCTAssertEqual(newDict[1].0, "banana")
    XCTAssertEqual(newDict[1].1, 2)
    XCTAssertEqual(newDict[2].0, "apple")
    XCTAssertEqual(newDict[2].1, 4)
    XCTAssertEqual(newDict.count, 3)

    newDict = dict! // swiftlint:disable:this force_unwrapping
    newDict.insert(value: 4, forKey: "apple", atIndex: 1)
    XCTAssertEqual(newDict["apple"], 4)
    XCTAssertEqual(newDict[0].0, "orange")
    XCTAssertEqual(newDict[0].1, 3)
    XCTAssertEqual(newDict[1].0, "apple")
    XCTAssertEqual(newDict[1].1, 4)
    XCTAssertEqual(newDict[2].0, "banana")
    XCTAssertEqual(newDict[2].1, 2)
    XCTAssertEqual(newDict.count, 3)

    let removed = dict.remove(at: 1)
    XCTAssertEqual(removed.0, "orange")
    XCTAssertEqual(removed.1, 3)
    XCTAssertEqual(dict[0].0, "apple")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict[1].0, "banana")
    XCTAssertEqual(dict[1].1, 2)
    XCTAssertEqual(dict.count, 2)
  }

  func testCollection() {
    dict = [
      "a": 1,
      "b": 2,
      "c": 3,
    ]

    XCTAssertEqual(dict.count, 3)
    XCTAssertEqual(dict.startIndex, 0)
    XCTAssertEqual(dict.endIndex, 3)
    XCTAssertEqual(dict.index(before: 2), 1)
    XCTAssertEqual(dict.index(after: 0), 1)
    XCTAssertEqual(dict.index(dict.startIndex, offsetBy: 2), 2)
    XCTAssertEqual(dict[0].0, "a")
    XCTAssertEqual(dict[0].1, 1)
    XCTAssertEqual(dict[1].0, "b")
    XCTAssertEqual(dict[1].1, 2)
    XCTAssertEqual(dict[2].0, "c")
    XCTAssertEqual(dict[2].1, 3)
  }

  func testSequence() {
    dict = [
      "a": 1,
      "b": 2,
      "c": 3,
    ]

    for (index, (key, value)) in dict.enumerated() {
      switch index {
      case 0:
        XCTAssertEqual(key, "a")
        XCTAssertEqual(value, 1)
      case 1:
        XCTAssertEqual(key, "b")
        XCTAssertEqual(value, 2)
      case 2:
        XCTAssertEqual(key, "c")
        XCTAssertEqual(value, 3)
      default:
        XCTFail("unexpected index")
      }
    }
  }

  func testEquatable() {
    do {
      let dict1 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
      let dict2 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
      expect(dict1) == dict2
    }

    do {
      let dict1 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
      let dict2 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 4])
      expect(dict1) != dict2
    }
  }

  func testHashable() {
    let dict1 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
    let dict2 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
    let dict3 = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 4])

    expect(dict1.hashValue) == dict2.hashValue
    expect(dict1.hashValue) != dict3.hashValue
  }

  func _testOrderedDictionaryPerformance() {
    let numberOfElements = 10000
    var orderedDictionary = OrderedDictionary<Int, Int>()

    for i in 0 ..< numberOfElements {
      orderedDictionary.append(value: i, forKey: i)
    }

    /**
     storage: keys in array, dictionary

     on iPhone 13 mini simulator 16.4

     [get_count] elapsed time: 4.016666207462549e-05
     [get_firstValue] elapsed time: 3.937500878237188e-05
     [get_lastValue] elapsed time: 3.925000783056021e-05
     [get_keys] elapsed time: 2.0000006770715117e-05
     [subscript_by_key] elapsed time: 0.26236179168336093
     [subscript_by_index] elapsed time: 0.3374214166542515
     [subscript_remove_key] elapsed time: 1.0261922499921639
     [append] elapsed time: 0.5462278749910183
     [pop_last] elapsed time: 0.35829812500742264
     [remove_value_for_key] elapsed time: 0.9810581250058021
     [remove_all] elapsed time: 5.062500713393092e-05
     [insert_at_head] elapsed time: 1.1053635416610632
     [insert_at_tail] elapsed time: 0.519063041661866
     [insert_at_middle] elapsed time: 0.8081304583174642
     [remove_at_index_head] elapsed time: 0.9248665000195615
     [remove_at_index_tail] elapsed time: 0.37208979166462086
     [remove_at_index_middle] elapsed time: 0.6600227500020992
     [iterate] elapsed time: 0.3434732500172686
     [get_values] elapsed time: 1.2010817083355505
     [iterate_values] elapsed time: 1.7022017916606274

     [get_count] elapsed time: 5.329164559952915e-05
     [get_firstValue] elapsed time: 4.029166302643716e-05
     [get_lastValue] elapsed time: 3.9208331145346165e-05
     [get_keys] elapsed time: 1.9416649593040347e-05
     [subscript_by_key] elapsed time: 0.2581664166646078
     [subscript_by_index] elapsed time: 0.33747766667511314
     [subscript_remove_key] elapsed time: 1.0261213750054594
     [append] elapsed time: 0.5502519166620914
     [pop_last] elapsed time: 0.3558691249927506
     [remove_value_for_key] elapsed time: 0.9793509583396371
     [remove_all] elapsed time: 4.904164234176278e-05
     [insert_at_head] elapsed time: 1.0852121250063647
     [insert_at_tail] elapsed time: 0.5163347916677594
     [insert_at_middle] elapsed time: 0.8039543333288748
     [remove_at_index_head] elapsed time: 0.9245552916545421
     [remove_at_index_tail] elapsed time: 0.3728757916542236
     [remove_at_index_middle] elapsed time: 0.6628992916666903
     [iterate] elapsed time: 0.34385470833512954
     [get_values] elapsed time: 1.202564541657921
     [iterate_values] elapsed time: 1.7233054583484773

     [get_count] elapsed time: 4.9250025767832994e-05
     [get_firstValue] elapsed time: 4.133331822231412e-05
     [get_lastValue] elapsed time: 4.050001734867692e-05
     [get_keys] elapsed time: 2.025000867433846e-05
     [subscript_by_key] elapsed time: 0.2655873333569616
     [subscript_by_index] elapsed time: 0.33954904167330824
     [subscript_remove_key] elapsed time: 1.0363550833426416
     [append] elapsed time: 0.5499375416547991
     [pop_last] elapsed time: 0.358059249992948
     [remove_value_for_key] elapsed time: 0.9785178750171326
     [remove_all] elapsed time: 4.8250018153339624e-05
     [insert_at_head] elapsed time: 1.0941922916681506
     [insert_at_tail] elapsed time: 0.5182582916750107
     [insert_at_middle] elapsed time: 0.8123944166582078
     [remove_at_index_head] elapsed time: 0.9201897083257791
     [remove_at_index_tail] elapsed time: 0.3733219583227765
     [remove_at_index_middle] elapsed time: 0.6599077916471288
     [iterate] elapsed time: 0.3394407500163652
     [get_values] elapsed time: 1.202721166657284
     [iterate_values] elapsed time: 1.7164653750078287

     [get_count] elapsed time: 4.512499435804784e-05
     [get_firstValue] elapsed time: 3.937500878237188e-05
     [get_lastValue] elapsed time: 4.2416679207235575e-05
     [get_keys] elapsed time: 1.9916653400287032e-05
     [subscript_by_key] elapsed time: 0.2606226250063628
     [subscript_by_index] elapsed time: 0.34481970834895037
     [subscript_remove_key] elapsed time: 1.0260219583578873
     [append] elapsed time: 0.5506903750065248
     [pop_last] elapsed time: 0.3595387499954086
     [remove_value_for_key] elapsed time: 0.9778360833297484
     [remove_all] elapsed time: 5.2624993259087205e-05
     [insert_at_head] elapsed time: 1.084534083318431
     [insert_at_tail] elapsed time: 0.5166817500139587
     [insert_at_middle] elapsed time: 0.799545041663805
     [remove_at_index_head] elapsed time: 0.9221114166721236
     [remove_at_index_tail] elapsed time: 0.37374641667702235
     [remove_at_index_middle] elapsed time: 0.6570778750174213
     [iterate] elapsed time: 0.3467813750030473
     [get_values] elapsed time: 1.1959635833336506
     [iterate_values] elapsed time: 1.6980707500188146

     [get_count] elapsed time: 4.5833352487534285e-05
     [get_firstValue] elapsed time: 4.208332393318415e-05
     [get_lastValue] elapsed time: 4.3166655814275146e-05
     [get_keys] elapsed time: 2.0500010577961802e-05
     [subscript_by_key] elapsed time: 0.2699791249760892
     [subscript_by_index] elapsed time: 0.3385567500081379
     [subscript_remove_key] elapsed time: 1.0191665416641627
     [append] elapsed time: 0.548760499979835
     [pop_last] elapsed time: 0.3621457499975804
     [remove_value_for_key] elapsed time: 0.981128458341118
     [remove_all] elapsed time: 4.5791646698489785e-05
     [insert_at_head] elapsed time: 1.0957787083170842
     [insert_at_tail] elapsed time: 0.5168245416716672
     [insert_at_middle] elapsed time: 0.8025551250029821
     [remove_at_index_head] elapsed time: 0.9219969999976456
     [remove_at_index_tail] elapsed time: 0.37350887499633245
     [remove_at_index_middle] elapsed time: 0.665481624979293
     [iterate] elapsed time: 0.3494531666801777
     [get_values] elapsed time: 1.2267362083366606
     [iterate_values] elapsed time: 1.7668201666674577

     [get_count] elapsed time: 4.016666207462549e-05
     [get_firstValue] elapsed time: 3.862500307150185e-05
     [get_lastValue] elapsed time: 3.883332828991115e-05
     [get_keys] elapsed time: 1.9500002963468432e-05
     [subscript_by_key] elapsed time: 0.26022170833311975
     [subscript_by_index] elapsed time: 0.331799499981571
     [subscript_remove_key] elapsed time: 1.0328806249890476
     [append] elapsed time: 0.5557753750181291
     [pop_last] elapsed time: 0.36386479166685604
     [remove_value_for_key] elapsed time: 1.0013369583466556
     [remove_all] elapsed time: 4.491666913963854e-05
     [insert_at_head] elapsed time: 1.1194801666715648
     [insert_at_tail] elapsed time: 0.5236703333503101
     [insert_at_middle] elapsed time: 0.8150698333338369
     [remove_at_index_head] elapsed time: 0.9389204166654963
     [remove_at_index_tail] elapsed time: 0.38025583332637325
     [remove_at_index_middle] elapsed time: 0.6744253750075586
     [iterate] elapsed time: 0.3350571249902714
     [get_values] elapsed time: 1.2189493333280552
     [iterate_values] elapsed time: 1.738447833340615
     */

    PerformanceMeasurer.measure(tag: "get_count", repeatCount: 100) {
      _ = orderedDictionary.count
    }

    PerformanceMeasurer.measure(tag: "get_firstValue", repeatCount: 100) {
      _ = orderedDictionary.firstValue
    }

    PerformanceMeasurer.measure(tag: "get_lastValue", repeatCount: 100) {
      _ = orderedDictionary.lastValue
    }

    PerformanceMeasurer.measure(tag: "get_keys", repeatCount: 100) {
      _ = orderedDictionary.keys
    }

    PerformanceMeasurer.measure(tag: "subscript_by_key", repeatCount: 100) {
      for i in 0 ..< numberOfElements {
        let _: Int? = orderedDictionary[i]
      }
    }

    PerformanceMeasurer.measure(tag: "subscript_by_index", repeatCount: 100) {
      for i in 0 ..< numberOfElements {
        let _: (Int, Int) = orderedDictionary[i]
      }
    }

    PerformanceMeasurer.measure(tag: "subscript_remove_key", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for i in 0 ..< numberOfElements {
        orderedDictionary[i] = nil
      }
    }

    PerformanceMeasurer.measure(tag: "append", repeatCount: 100) {
      var orderedDictionary = OrderedDictionary<Int, Int>()
      for i in 0 ..< numberOfElements {
        orderedDictionary.append(value: i, forKey: i)
      }
    }

    PerformanceMeasurer.measure(tag: "pop_last", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for _ in 0 ..< numberOfElements {
        orderedDictionary.popLast()
      }
    }

    PerformanceMeasurer.measure(tag: "remove_value_for_key", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for i in 0 ..< numberOfElements {
        orderedDictionary.removeValue(forKey: i)
      }
    }

    PerformanceMeasurer.measure(tag: "remove_all", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      orderedDictionary.removeAll()
    }

    PerformanceMeasurer.measure(tag: "insert_at_head", repeatCount: 100) {
      var orderedDictionary = OrderedDictionary<Int, Int>()
      for i in 0 ..< numberOfElements {
        orderedDictionary.insert(value: i, forKey: i, atIndex: 0)
      }
    }

    PerformanceMeasurer.measure(tag: "insert_at_tail", repeatCount: 100) {
      var orderedDictionary = OrderedDictionary<Int, Int>()
      for i in 0 ..< numberOfElements {
        orderedDictionary.insert(value: i, forKey: i, atIndex: i)
      }
    }

    PerformanceMeasurer.measure(tag: "insert_at_middle", repeatCount: 100) {
      var orderedDictionary = OrderedDictionary<Int, Int>()
      for i in 0 ..< numberOfElements {
        orderedDictionary.insert(value: i, forKey: i, atIndex: i / 2)
      }
    }

    PerformanceMeasurer.measure(tag: "remove_at_index_head", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for _ in 0 ..< numberOfElements {
        orderedDictionary.remove(at: 0)
      }
    }

    PerformanceMeasurer.measure(tag: "remove_at_index_tail", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for _ in 0 ..< numberOfElements {
        orderedDictionary.remove(at: orderedDictionary.count - 1)
      }
    }

    PerformanceMeasurer.measure(tag: "remove_at_index_middle", repeatCount: 100) {
      var orderedDictionary = orderedDictionary
      for _ in 0 ..< numberOfElements {
        orderedDictionary.remove(at: orderedDictionary.count / 2)
      }
    }

    PerformanceMeasurer.measure(tag: "iterate", repeatCount: 100) {
      for (key, value) in orderedDictionary {
        _ = (key, value)
      }
    }

    /**
     1) use simple array with `reserveCapacity`.
     [get_values] elapsed time: 1.2076257083099335
     [iterate_values] elapsed time: 1.69190962499124

     [get_values] elapsed time: 1.2133822916657664
     [iterate_values] elapsed time: 1.70010362501489

     2) `public var values: [ValueType] { keys.lazy.map { dictionary[$0]! } }`
     [get_values] elapsed time: 1.53960779166664
     [iterate_values] elapsed time: 1.9964713749941438

     [get_values] elapsed time: 1.5227190416771919
     [iterate_values] elapsed time: 2.02713162501459
     */

    PerformanceMeasurer.measure(tag: "get_values", repeatCount: 1000) {
      _ = orderedDictionary.values
    }

    PerformanceMeasurer.measure(tag: "iterate_values", repeatCount: 1000) {
      for value in orderedDictionary.values {
        _ = value
      }
    }

    // Measure the time taken to insert elements.
    measure {
      _ = orderedDictionary.values
    }
  }
}

extension OrderedDictionaryTests {

  func testFirstKeyForValue() {
    dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 3])
    XCTAssertEqual(dict[firstKeyFor: 2], "b")
    XCTAssertEqual(dict[firstKeyWhere: { $0 == 3 }], "c")
  }

  func testAllKeysForValue() {
    dict = OrderedDictionary<String, Int>(keys: ["a", "b", "c"], values: [1, 2, 2])
    XCTAssertEqual(dict.allKeys(for: 2).sorted(), ["b", "c"].sorted())
    XCTAssertEqual(dict.allKeys(where: { $0 == 2 }).sorted(), ["b", "c"].sorted())
  }
}

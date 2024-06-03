//
//  DispatchTimer.swift
//
//  Created by Honghao Zhang on 3/28/21.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/**
 A timer backed by `DispatchSourceTimer`.

 Examples:
 ```
 // make one and fire later
 let timer = DispatchTimer(queue: .main) {
   // ...
 }

 timer.fire(
   every: .seconds(0.25),
   leeway: .fractional(0.2),
   fireImmediately: true
 )
 ```

 ```
 // make a running one
 timer = DispatchTimer.repeatingTimer(
   every: .seconds(0.25),
   fireImmediately: true,
   queue: .main,
   block: {
     ...
   }
 )
 ```
 */
public final class DispatchTimer {

  /// Create a running repeating timer.
  ///
  /// - Parameters:
  ///   - interval: The timer repeating interval in seconds.
  ///   - isStrict: If the timer should be strict. If `true`, the system makes its best effort to follow the timer's specified leeway value. Default to `false`.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  ///   - queue: The timer callback queue. Default to `.main`.
  ///   - block: The timer callback block.
  /// - Returns: A running repeating timer.
  public static func repeatingTimer(every interval: TimeInterval,
                                    isStrict: Bool = false,
                                    leeway: TimerLeeway = .fractional(0.1),
                                    fireImmediately: Bool = false,
                                    queue: DispatchQueue = .main,
                                    block: @escaping (() -> Void)) -> DispatchTimer
  {
    repeatingTimer(
      every: .seconds(interval),
      isStrict: isStrict,
      leeway: leeway,
      fireImmediately: fireImmediately,
      queue: queue,
      block: block
    )
  }

  /// Create a running repeating timer.
  ///
  /// - Parameters:
  ///   - interval: The timer repeating duration.
  ///   - isStrict: If the timer should be strict. If `true`, the system makes its best effort to follow the timer's specified leeway value. Default to `false`.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  ///   - queue: The timer callback queue. Default to `.main`.
  ///   - block: The timer callback block.
  /// - Returns: A running repeating timer.
  public static func repeatingTimer(every interval: Duration,
                                    isStrict: Bool = false,
                                    leeway: TimerLeeway = .fractional(0.1),
                                    fireImmediately: Bool = false,
                                    queue: DispatchQueue = .main,
                                    block: @escaping (() -> Void)) -> DispatchTimer
  {
    let timer = DispatchTimer(isStrict: isStrict, queue: queue, block: block)
    timer.fire(every: interval, leeway: leeway, fireImmediately: fireImmediately)
    return timer
  }

  /// Create a scheduled timer that fires once after a specified interval.
  ///
  /// - Parameters:
  ///   - interval: The delay interval in seconds.
  ///   - isStrict: If the timer should be strict. If `true`, the system makes its best effort to follow the timer's specified leeway value. Default to `false`.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  ///   - queue: The timer callback queue. Default to `.main`.
  ///   - block: The timer callback block.
  /// - Returns: A scheduled timer.
  public static func delayTimer(after interval: TimeInterval,
                                isStrict: Bool = false,
                                leeway: TimerLeeway = .fractional(0.1),
                                queue: DispatchQueue = .main,
                                block: @escaping (() -> Void)) -> DispatchTimer
  {
    delayTimer(
      after: .seconds(interval),
      isStrict: isStrict,
      leeway: leeway,
      queue: queue,
      block: block
    )
  }

  /// Create a scheduled timer that fires once after a specified interval.
  ///
  /// - Parameters:
  ///   - interval: The delay duration.
  ///   - isStrict: If the timer should be strict. If `true`, the system makes its best effort to follow the timer's specified leeway value. Default to `false`.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  ///   - queue: The timer callback queue. Default to `.main`.
  ///   - block: The timer callback block.
  /// - Returns: A scheduled timer.
  public static func delayTimer(after interval: Duration,
                                isStrict: Bool = false,
                                leeway: TimerLeeway = .fractional(0.1),
                                queue: DispatchQueue = .main,
                                block: @escaping (() -> Void)) -> DispatchTimer
  {
    let timer = DispatchTimer(isStrict: isStrict, queue: queue, block: block)
    timer.fire(after: interval, leeway: leeway)
    return timer
  }

  private let queue: DispatchQueue
  private let timer: DispatchSourceTimer

  /// The main callback block.
  private let block: BlockVoid

  /// Extra callback blocks.
  private lazy var extraBlocks: OrderedDictionary<String, BlockVoid> = [:]

  /// If the timer is scheduled. Applicable to both repeating and delay timers.
  private var isScheduled: Bool { interval != nil }

  /// The repeating interval or the delay interval.
  public private(set) var interval: TimeInterval?

  /// Make a new timer.
  ///
  /// - Parameters:
  ///   - isStrict: If the timer should be strict. If `true`, the system makes its best effort to follow the timer's specified leeway value. Default to `false`.
  ///   - queue: The timer callback queue.
  ///   - block: The timer callback block.
  public init(isStrict: Bool = false, queue: DispatchQueue, block: @escaping (() -> Void)) {
    self.queue = queue
    self.block = block

    self.timer = isStrict ?
      DispatchSource.makeTimerSource(flags: .strict, queue: queue) :
      DispatchSource.makeTimerSource(queue: queue)

    timer.setEventHandler { [weak self] in
      self?.callCallbackBlocks()
    }

    timer.resume()
  }

  deinit {
    cancel()
  }

  private func callCallbackBlocks() {
    block()
    extraBlocks.values.forEach { block in
      block()
    }
  }

  // MARK: - Fire repeatedly

  /// Schedule the timer to repeatedly fire at a specified interval.
  ///
  /// A timer can only be scheduled once, you should create a new timer if you need to change the interval.
  ///
  /// - Parameters:
  ///   - interval: The timer repeating interval in seconds.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  public func fire(every interval: TimeInterval, leeway: TimerLeeway = .fractional(0.1), fireImmediately: Bool = false) {
    fire(every: .seconds(interval), leeway: leeway, fireImmediately: fireImmediately)
  }

  /// Schedule the timer to repeatedly fire at a specified duration.
  ///
  /// A timer can only be scheduled once, you should create a new timer if you need to change the interval.
  ///
  /// - Parameters:
  ///   - interval: The timer repeating duration.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  public func fire(every interval: Duration, leeway: TimerLeeway = .fractional(0.1), fireImmediately: Bool = false) {
    fire(every: interval.dispatchTimeInterval(assertIfNotExact: false), leeway: leeway.dispatchTimeInterval(from: interval.seconds), fireImmediately: fireImmediately)
  }

  /// Schedule the timer to repeatedly fire at a specified interval.
  ///
  /// A timer can only be scheduled once, you should create a new timer if you need to change the interval.
  ///
  /// - Parameters:
  ///   - interval: The timer repeating interval.
  ///   - leeway: The leeway for the timer. Default to 10% of the repeating interval.
  ///   - fireImmediately: If the timer should fire immediately. By default, it will fire for the first time after an interval.
  private func fire(every interval: DispatchTimeInterval, leeway: DispatchTimeInterval, fireImmediately: Bool = false) {
    guard isTimerGoodToSchedule() else {
      return
    }

    let interval = interval.timeInterval
    guard interval > 0 else {
      ChouTi.assertFailure("repeating duration should be greater than zero.", metadata: ["interval": "\(interval)"])
      return
    }

    self.interval = interval
    if fireImmediately {
      queue.asyncIfNeeded { [weak self] in
        self?.callCallbackBlocks()
      }
    }

    /// FYI, in GrandCentralDispatch, you can schedule a DispatchSourceTimer by either `wallDeadline`
    /// or `deadline`, which respectively `do` and `do not` count the time while the Mac is asleep.
    /// https://www.hackingwithswift.com/forums/macos/running-a-task-in-background-every-second/15091/15116
    ///
    /// 10s timer
    /// deadline:
    /// 2022-11-13 09:24:56.925740-0800 ChouTi Playground[96722:15844638] schedule
    /// 2022-11-13 09:25:41.670448-0800 ChouTi Playground[96722:15844638] fired
    ///
    /// wallDeadline:
    /// 2022-11-13 09:28:06.826729-0800 ChouTi Playground[96890:15851840] schedule
    /// 2022-11-13 09:28:17.086252-0800 ChouTi Playground[96890:15851840] fired
    timer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
  }

  // MARK: - Fire once

  /// Schedule the timer to fire after the specified interval.
  ///
  /// A timer can only be scheduled once, you should create a new timer if you need to change the interval.
  ///
  /// - Parameters:
  ///   - interval: The interval in seconds after which to fire the timer.
  ///   - leeway: The leeway for the timer. Default to 10% of the delay interval.
  public func fire(after interval: TimeInterval, leeway: TimerLeeway = .fractional(0.1)) {
    fire(after: .seconds(interval), leeway: leeway)
  }

  /// Schedule the timer to fire after the specified interval.
  ///
  /// A timer can only be scheduled once, you should create a new timer if you need to change the interval.
  ///
  /// - Parameters:
  ///   - interval: The interval in seconds after which to fire the timer.
  ///   - leeway: The leeway for the timer. Default to 10% of the delay interval.
  public func fire(after interval: Duration, leeway: TimerLeeway = .fractional(0.1)) {
    fire(after: interval.dispatchTimeInterval(assertIfNotExact: false), leeway: leeway.dispatchTimeInterval(from: interval.seconds))
  }

  private func fire(after interval: DispatchTimeInterval, leeway: DispatchTimeInterval) {
    guard isTimerGoodToSchedule() else {
      return
    }

    let interval = interval.timeInterval
    guard interval > 0 else {
      ChouTi.assertFailure("delay duration should be greater than zero.", metadata: ["interval": "\(interval)"])
      return
    }

    self.interval = interval
    timer.schedule(deadline: .now() + interval, leeway: leeway)
  }

  // MARK: - Add additional blocks

  /// Add extra callback block.
  /// - Parameters:
  ///   - key: The key for the block, used to uniquely identify the block.
  ///   - assertIfExists: If assert if the key already exists. Default to `true`.
  ///   - block: The block to add.
  public func addBlock(key: String, assertIfExists: Bool = true, _ block: @escaping BlockVoid) {
    if assertIfExists {
      ChouTi.assert(!extraBlocks.hasKey(key), "duplicated block key", metadata: ["key": "\(key)"])
    }
    extraBlocks[key] = block
  }

  /// Remove the extra block by key.
  /// - Parameters:
  ///   - key: The key for the block.
  ///   - assertIfNotExists: If assert if the key does not exist. Default to `true`.
  public func removeBlock(key: String, assertIfNotExists: Bool = true) {
    if assertIfNotExists {
      ChouTi.assert(extraBlocks.hasKey(key), "missing block key", metadata: ["key": "\(key)"])
    }
    extraBlocks.removeValue(forKey: key)
  }

  /// Cancel the timer.
  ///
  /// The timer cannot be reused anymore after this call.
  public func cancel() {
    timer.cancel()
  }

  private func isTimerGoodToSchedule() -> Bool {
    guard !timer.isCancelled else {
      ChouTi.assertFailure("Timer is already cancelled. You should create a new timer.")
      return false
    }

    guard !isScheduled else {
      ChouTi.assertFailure("Timer is already scheduled. You should create a new timer.")
      return false
    }

    return true
  }

  // MARK: - Testing

  #if DEBUG

  var test: Test { Test(host: self) }

  struct Test {

    private let host: DispatchTimer

    fileprivate init(host: DispatchTimer) {
      ChouTi.assert(Thread.isRunningXCTest, "test namespace should only be used in test target.")
      self.host = host
    }

    var extraBlocks: OrderedDictionary<String, BlockVoid> { host.extraBlocks }
  }

  #endif
}

// Notes:
// NSTimer events are always a little later than they are scheduled.
// GCD events with a leeway setting can be a little early or a little late.
//
// Reference:
//   - https://stackoverflow.com/a/55329816/3164091

/**
 iOS firing timer in the background

 Scheduled NSTimer when app is in background?
 https://stackoverflow.com/a/17445799/3164091
 */

/**
 Energy Efficiency Guide for Mac Apps
 https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/WWDCVideos.html#//apple_ref/doc/uid/TP40013929-CH21-SW1
 https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/RelatedDocuments.html#//apple_ref/doc/uid/TP40013929-CH20-SW1

 Occlusion Notifications
 App level and window level, notifications

 Active App Transitions
 resign active, become active

 Scheduling Background Activity
 `ProcessInfo`

 Disable App Nap in macOS
 http://arsenkin.com/Disable-app-nap.html
 */

/**
 High precision timer:
 https://github.com/sononum/SOHPTimer

 High Precision Timers in iOS / OS X
 https://developer.apple.com/library/archive/technotes/tn2169/_index.html

 A Cocoa timer class for iOS and OS X offering a choice of behaviors, so you can use the right one.
 https://github.com/jmah/MyLilTimer
 */

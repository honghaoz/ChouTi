# CHANGELOG

## [0.0.10](https://github.com/honghaoz/ChouTi/releases/tag/0.0.10) (2026-01-04)

- Framework `ChouTi`:
  - Added `cancelOnDeallocate` option to cancellable tokens so that the cancel block can be not called on deallocate.
  - Added `SimpleCancellableToken`.
  - Updated cancellable tokens to only call the cancel block once.
  - Updated `Device.DeviceType` cases.
  - Minor updates in NSAttributedString utilities.

- Framework `ChouTiTest`:
  - Added time measurement utilities.
  - Added `skip`, `skipIf` and `skipUnless` utilities.
  - Added `Environment` utility.
  - Added `TestWindow` utility.

## [0.0.9](https://github.com/honghaoz/ChouTi/releases/tag/0.0.9) (2025-02-26)

- Fixed CGRect utilities.
- Added log file exporting capabilities.
- Updated `Trigger` to support publisher and binding.
- Updated `Binding` to support bidirectional data sync with `CurrentValueSubject`.
- Fixed watchOS build issues.
- Minor bug fixes.

## [0.0.8](https://github.com/honghaoz/ChouTi/releases/tag/0.0.8) (2024-09-28)

- Bumped up swift-tools-version to 5.9.
- Fixed package platform issues on tvOS and watchOS.
- Added playgrounds for all platforms.
- Added CI workflows for building playgrounds with ChouTi releases on all platforms.

## [0.0.7](https://github.com/honghaoz/ChouTi/releases/tag/0.0.7) (2024-09-27)

- Framework `ChouTi`:
  - Added watchOS support.
  - Added `ResultBuilder`, `ArrayBuilder` and more builders.
  - Added `Binding` and `Trigger` utilities.
  - Added `Debounce` and `Throttle` utilities.
  - Added `DynamicLookup` and `TypeEraseWrapper` utilities.
  - Added `Clock` and `MockClock` utilities.
  - Added data structures `LinkedList`, `Queue` and `Tree`.
  - Added data encoding, decoding and hashing utilities.
  - Added `Angle`.
  - Added geometry extensions (`CGPoint`, `CGSize`, `CGRect`, `CGVector`, `CGAffineTransform` and `CATransform3D`).
  - Added `KVOObservable`.
  - Added `CancellableToken`
  - Added `DeallocationNotifiable`
  - Other various utilities and extensions.
- Framework `ChouTiTest`:
  - Fixed an issue that `Any?` type is not supported by `expect`.

## [0.0.6](https://github.com/honghaoz/ChouTi/releases/tag/0.0.6) (2024-08-29)

- Framework `ChouTi`:
  - Added `BinaryFloatingPoint` rounding utilities.
  - Added `FloatingPoint.isApproximatelyEqual`
  - Added `CGPoint`, `CGSize` and `CGRect` utilities.
  - Added `clamp` and `lerp` utilities.
  - Added `Encrypt` and `Obfuscation` utilities.
  - Added `AssociatedObject` utilities.
  - Added `System` utilities.
  - Added tvOS & visionOS support.
  - Improved documentation.

## [0.0.5](https://github.com/honghaoz/ChouTi/releases/tag/0.0.5) (2024-08-16)

- Added a sync version of `PerformanceMeasurer`.
- `FileLogDestination` now uses a background queue to write logs.
- Added `countryFlagEmoji` to `String`.

## [0.0.4](https://github.com/honghaoz/ChouTi/releases/tag/0.0.4) (2024-06-12)

- Increased code coverage.
- Framework `ChouTi`:
  - Added `Device.uuid()`
  - Updated `MachTimeId.id()` to generate an absolute unique ID.
  - Updated `DelayTask` with simplified `cancel` and internal locks.
  - Updated `isRunningXCTest` to a static method of `Thread`.
  - Fixed `DispatchGroup.async()` to not call `work` block if timed out.
  - Removed `makeSerialQueue`, use `make(...)` instead.
- Framework `ChouTiTest`:
  - Updated: `import ChouTiTest` now imports `XCTest` as well.
- Various scripts update.

## [0.0.3](https://github.com/honghaoz/ChouTi/releases/tag/0.0.3) (2024-05-26)

- Framework `ChouTi`:
  - Added various Box utilities
  - Added `DelayTask` and various GCD (Grand Central Dispatch) utilities
  - Added `Duration`
  - Added `DispatchTimer`
  - Added `MemoryWarningPublisher`
  - Other various utilities and extensions
  - Increased test coverage

- Framework `ChouTiTest`:
  - Added `toEventually(_:interval:timeout:)` expression operator
  - Added `toEventuallyNot(_:interval:timeout:)` expression operator
  - Added `beApproximatelyEqual(to:)` expectation
  - Added `beGreaterThan(_:)` expectation
  - Added `beGreaterThanOrEqual(to:)` expectation
  - Added `beLessThan(_:)` expectation
  - Added `beLessThanOrEqual(to:)` expectation
  - Increased test coverage

## [0.0.2](https://github.com/honghaoz/ChouTi/releases/tag/0.0.2) (2024-05-20)

- Add framework `ChouTi`.

## [0.0.1](https://github.com/honghaoz/ChouTi/releases/tag/0.0.1) (2024-05-17)

- Initial release 🎉
- Added framework `ChouTiTest`.

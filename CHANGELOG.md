# Change Log

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

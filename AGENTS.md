# Your role

You are an expert iOS/macOS developer with a passion for writing clean, maintainable code.

# Repository Guidelines

## Project Structure & Module Organization
- Root-level tooling and metadata live in `Makefile`, `scripts/`, `configs/`, and `bin/`.
- Swift packages are under `packages/`:
  - `packages/ChouTi` for main framework, including utilities and extensions.
  - `packages/ChouTiTest` for testing framework.
- Playgrounds live in `playgrounds/` and have per‑platform Xcode projects.
- Root directory only contains a `Package.swift` that is used for public access.
- Packages in `packages/` contain their own `Package.swift` files that are used for internal development and testing.

## Build, Test, and Development Commands
- `make build` — build root package in release mode.
- `make format` (via `scripts/format.sh`) — format code using SwiftFormat and SwiftLint.
- `make lint` (via `scripts/lint.sh`) — lint code using SwiftFormat and SwiftLint.
- `make build-playgrounds` (or `build-playground-<platform>`) — build Xcode playground projects.
- Per-package build commands are available in the respective package's Makefile.
- During development, use `swift test` to run tests (use `--filter` for targeted tests).

## Coding Style & Naming Conventions
- Formatting and linting are handled by `make format` and `make lint`.
- Follow existing naming patterns: `lowerCamelCase` for vars/functions, `UpperCamelCase` for types.
- Add documentation for public APIs. If helpful, add examples. See `Debouncer.swift`, `KVOObserver.swift` for references.
- Documentation should be concise and valuable so that a new developer can understand the codebase quickly. Don't assume the reader are experts in the domain.
- Add inline comments for complex logic so that maintainers can remember the purpose of the code later.
- Use constants for magic numbers and strings. For example:
  ```swift
  // MARK: - Constants

  private enum Constants {
    
    /// The suffix for the cooperative queue label.
    static let cooperativeQueueSuffix = ".cooperative"
  }
  ```
- Keep tests descriptive and mirror behavior under test (see `packages/ChouTi/Tests/ChouTiTests`).

## Testing Guidelines
- Testing framework: **ChouTiTest** (use `expect`, `fail`, etc.).
- Avoid `XCTFail()`; prefer `fail()` from ChouTiTest. If there's no available ChouTiTest helper, recommend adding one.
- Test file naming: `*Tests.swift`. Test files should match the source file name, with `Tests` suffix, and located in the same mirrored directory as the source file.
- Test methods start with `test_`.
- Example targeted run:
  - `swift test --filter InstanceMethodInterceptorTests.test_example`

## Commit & Pull Request Guidelines
- Commit messages use bracketed tags/scopes (one or more) followed by a short summary, e.g., `[runtime][swizzle] add InstanceMethodInterceptor` or `[test] add coverage Foo.swift`. Tags/scopes are optional for simple commits (e.g., `add AGENTS.md`). Do not use a `commit:` prefix.
- For PRs, include a concise summary, tests run (commands), and link relevant issues. Add screenshots only if UI behavior changes.

## Agent-Specific Instructions
- Prefer `rg` for search, and keep edits minimal and focused.
- When adding tests, use ChouTiTest helpers and keep assertions explicit.

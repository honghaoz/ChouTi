//
//  group-imports.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/3/26.
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

// The entry point of `group-imports.sh`, which compiles it with the grouping's logic, `ImportGroups.swift`, next to it,
// which `ImportGroupsTests.swift` tests.
//
// Usage: group-imports --fix|--check <config> <repository>
//
// Groups the imports at the top of the Swift files that the configuration applies to. `--fix` rewrites the files whose
// imports aren't grouped, and `--check` lists them and exits with 1 when there are any. Both list the files whose
// imports can't be grouped, and exit with 1 for them.

import Foundation

@main
enum GroupImports {

  static func main() {
    let arguments = CommandLine.arguments
    guard arguments.count == 4, arguments[1] == "--fix" || arguments[1] == "--check" else {
      print("usage: group-imports --fix|--check <config> <repository>")
      exit(2)
    }

    let status: Int32
    do {
      status = try run(fixes: arguments[1] == "--fix", configPath: arguments[2], repository: URL(fileURLWithPath: arguments[3]))
    } catch let error as ImportGroups.ConfigError {
      print("🛑 \(arguments[2]): \(error)")
      status = 2
    } catch {
      print("🛑 \(error.localizedDescription)")
      status = 2
    }
    exit(status)
  }

  /// Groups or checks the imports of the files that a configuration applies to, and lists the files.
  ///
  /// - Parameters:
  ///   - fixes: Whether to rewrite the files whose imports aren't grouped, instead of listing them.
  ///   - configPath: The configuration's path.
  ///   - repository: The repository.
  /// - Returns: The exit status: 1 when a file's imports can't be grouped, or, when checking, aren't grouped, and 0
  ///   otherwise.
  static func run(fixes: Bool, configPath: String, repository: URL) throws -> Int32 {
    let repository = repository.resolvingSymlinksInPath()
    let config = try ImportGroups.Config(parsing: String(contentsOfFile: configPath, encoding: .utf8))

    var isAnyNotGrouped = false
    var isAnyUnsupported = false
    for path in try ImportGroups.swiftFiles(config: config, repository: repository) {
      // each file is listed once it's handled, so that the files rewritten before an error are listed
      let url = repository.appendingPathComponent(path)
      let text = try String(contentsOf: url, encoding: .utf8)
      switch ImportGroups.group(text, config: config) {
      case .grouped(let grouped):
        if fixes {
          if grouped != text {
            try grouped.write(to: url, atomically: true, encoding: .utf8)
            print("✏️  Grouped the imports of \(path)")
          }
        } else if !ImportGroups.hasSameGroups(text, as: grouped) {
          print("🛑 \(path): the imports aren't grouped, run `make format`")
          isAnyNotGrouped = true
        }
      case .unsupported(let line, let reason):
        print("🛑 \(path):\(line): \(reason), so its imports can't be grouped")
        isAnyUnsupported = true
      }
    }
    return isAnyUnsupported || isAnyNotGrouped ? 1 : 0
  }
}

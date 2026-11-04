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

    do {
      try run(fixes: arguments[1] == "--fix", configPath: arguments[2], repository: URL(fileURLWithPath: arguments[3]))
    } catch let error as ImportGroups.ConfigError {
      print("🛑 \(arguments[2]): \(error)")
      exit(2)
    } catch {
      print("🛑 \(error.localizedDescription)")
      exit(2)
    }
  }

  /// Groups or checks the imports of the files that a configuration applies to, and exits with the result.
  ///
  /// - Parameters:
  ///   - fixes: Whether to rewrite the files whose imports aren't grouped, instead of listing them.
  ///   - configPath: The configuration's path.
  ///   - repository: The repository.
  static func run(fixes: Bool, configPath: String, repository: URL) throws {
    let repository = repository.resolvingSymlinksInPath()
    let config = try ImportGroups.Config(parsing: String(contentsOfFile: configPath, encoding: .utf8))

    var notGrouped: [String] = []
    var unsupported: [String] = []
    for path in try swiftFiles(config: config, repository: repository) {
      let url = repository.appendingPathComponent(path)
      let text = try String(contentsOf: url, encoding: .utf8)
      switch ImportGroups.group(text, config: config) {
      case .grouped(let grouped):
        if fixes {
          if grouped != text {
            try grouped.write(to: url, atomically: true, encoding: .utf8)
            notGrouped.append(path)
          }
        } else if !ImportGroups.hasSameGroups(text, as: grouped) {
          notGrouped.append(path)
        }
      case .unsupported(let line, let reason):
        unsupported.append("\(path):\(line): \(reason), so its imports can't be grouped")
      }
    }

    for path in notGrouped {
      print(fixes ? "✏️  Grouped the imports of \(path)" : "🛑 \(path): the imports aren't grouped, run `make format`")
    }
    for problem in unsupported {
      print("🛑 \(problem)")
    }
    exit(unsupported.isEmpty && (fixes || notGrouped.isEmpty) ? 0 : 1)
  }

  /// Returns the Swift files that a configuration applies to, relative to the repository, in order.
  ///
  /// The hidden files and folders in a directory are left out, such as `.build`, where SwiftPM puts generated Swift files,
  /// and the excluded folders aren't walked. A symbolic link to a file outside the repository is left out, as the file
  /// isn't the repository's, and a directory that can't be read throws, so that its files aren't left out without a word.
  ///
  /// - Parameters:
  ///   - config: The configuration.
  ///   - repository: The repository, with its symbolic links resolved.
  /// - Returns: The files' paths.
  static func swiftFiles(config: ImportGroups.Config, repository: URL) throws -> [String] {
    // the path of a file relative to the repository, with its symbolic links resolved, `nil` for a file outside it
    func relativePath(of url: URL) -> String? {
      let path = url.resolvingSymlinksInPath().path
      return path.hasPrefix(repository.path + "/") ? String(path.dropFirst(repository.path.count + 1)) : nil
    }
    func isExcluded(_ relativePath: String) -> Bool {
      config.excludedPaths.contains { relativePath == $0 || relativePath.hasPrefix($0 + "/") }
    }

    let fileManager = FileManager.default
    var files: [String] = []
    for path in config.paths {
      let url = repository.appendingPathComponent(path)
      var isDirectory: ObjCBool = false
      guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
        throw ImportGroups.ConfigError("\(path) doesn't exist")
      }

      var urls: [URL] = []
      if isDirectory.boolValue {
        var enumerationError: Error?
        let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles], errorHandler: { _, error in
          enumerationError = error
          return false
        })
        guard let enumerator else {
          throw ImportGroups.ConfigError("\(path) can't be read")
        }
        while let item = enumerator.nextObject() as? URL {
          // an excluded folder isn't walked, so that one that can't be read doesn't stop the run
          if let relativePath = relativePath(of: item), isExcluded(relativePath) {
            enumerator.skipDescendants()
          } else {
            urls.append(item)
          }
        }
        if let enumerationError {
          throw enumerationError
        }
      } else {
        urls = [url]
      }
      for file in urls where file.pathExtension == "swift" {
        if let relativePath = relativePath(of: file), !isExcluded(relativePath) {
          files.append(relativePath)
        }
      }
    }
    return files.sorted()
  }
}

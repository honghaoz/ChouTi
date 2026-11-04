//
//  ImportGroups.swift
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

import Foundation

/// Groups the imports at the top of a Swift file, for `scripts/imports/group-imports.sh`.
///
/// The imports go in the groups of a configuration, in its order, with a blank line between groups. In a group, the
/// `#if` blocks of imports come first, and the order of the other imports is left to SwiftFormat's `sortImports`, so the
/// two tools can't disagree.
///
/// The test target of `scripts/imports/Package.swift` compiles this file to test it, and the script compiles it with
/// its entry point, `scripts/imports/group-imports.swift`, so it uses Foundation only.
enum ImportGroups {

  /// The groups of the imports, and the files they apply to.
  struct Config: Equatable {

    /// The groups, in order, each with the modules it takes.
    let groups: [Set<String>]

    /// The index of the group that takes the modules that no group lists.
    let otherModulesGroup: Int

    /// The directories and files whose Swift files the groups apply to, relative to the repository.
    let paths: [String]

    /// The directories and files in the paths that the groups don't apply to, relative to the repository.
    let excludedPaths: [String]

    /// Creates a configuration.
    ///
    /// The paths are kept without their `.` and empty components, as in `./Sources/` or `Tests//Unit`, so that they're
    /// in the form of the paths relative to the repository that they're compared with.
    ///
    /// - Parameters:
    ///   - groups: The groups, in order, each with the modules it takes.
    ///   - otherModulesGroup: The index of the group that takes the modules that no group lists.
    ///   - paths: The directories and files whose Swift files the groups apply to, relative to the repository.
    ///   - excludedPaths: The directories and files in the paths that the groups don't apply to.
    init(groups: [Set<String>], otherModulesGroup: Int, paths: [String], excludedPaths: [String]) {
      func normalized(_ path: String) -> String {
        path.split(separator: "/").filter { $0 != "." }.joined(separator: "/")
      }
      self.groups = groups
      self.otherModulesGroup = otherModulesGroup
      self.paths = paths.map { normalized($0) }
      self.excludedPaths = excludedPaths.map { normalized($0) }
    }

    /// Creates a configuration from its text.
    ///
    /// Each line is a key and its values, separated by spaces, and a `#` starts a comment:
    /// - `paths: <path>...`: The directories and files whose Swift files the groups apply to, without the files and
    ///   folders in the directories whose names start with a dot, such as `.build`.
    /// - `exclude: <path>...`: The directories and files in the paths that the groups don't apply to.
    /// - `group: <module>...`: A group's modules, in the order of the groups, with `*` for the modules that no group
    ///   lists.
    ///
    /// - Parameter text: The configuration's text.
    init(parsing text: String) throws {
      var groups: [Set<String>] = []
      var otherModulesGroup: Int?
      var paths: [String] = []
      var excludedPaths: [String] = []
      for (offset, rawLine) in text.components(separatedBy: "\n").enumerated() {
        let line = rawLine.prefix(while: { $0 != "#" }).trimmingCharacters(in: .whitespaces)
        guard !line.isEmpty else {
          continue
        }
        guard let colon = line.firstIndex(of: ":") else {
          throw ConfigError("line \(offset + 1): expected a key and its values, as `key: values`")
        }

        let key = line[..<colon].trimmingCharacters(in: .whitespaces)
        let values = line[line.index(after: colon)...].split(whereSeparator: \.isWhitespace).map { String($0) }
        switch key {
        case "paths":
          paths += values
        case "exclude":
          excludedPaths += values
        case "group":
          if values == ["*"] {
            guard otherModulesGroup == nil else {
              throw ConfigError("line \(offset + 1): a second group for the modules that no group lists")
            }
            otherModulesGroup = groups.count
            groups.append([])
          } else {
            guard !values.isEmpty, !values.contains("*") else {
              throw ConfigError("line \(offset + 1): a group lists its modules, or is `*` alone")
            }
            if let module = values.first(where: { module in groups.contains { $0.contains(module) } }) {
              throw ConfigError("line \(offset + 1): \(module) is in two groups")
            }
            groups.append(Set(values))
          }
        default:
          throw ConfigError("line \(offset + 1): unknown key `\(key)`")
        }
      }

      guard let otherModulesGroup else {
        throw ConfigError("no `group: *` for the modules that no group lists")
      }
      guard !paths.isEmpty else {
        throw ConfigError("no `paths` to apply the groups to")
      }
      self.init(groups: groups, otherModulesGroup: otherModulesGroup, paths: paths, excludedPaths: excludedPaths)
    }

    /// Returns the index of a module's group, from the module's first component, so that a submodule goes with its
    /// module.
    ///
    /// - Parameter module: The module, such as `UIKit` or `UIKit.UIGestureRecognizerSubclass`.
    /// - Returns: The index of the module's group.
    func group(of module: String) -> Int {
      let name = String(module.prefix(while: { $0 != "." }))
      return groups.firstIndex(where: { $0.contains(name) }) ?? otherModulesGroup
    }
  }

  /// An error in a configuration.
  struct ConfigError: Error, Equatable, CustomStringConvertible {

    /// What's wrong, with the line when it's about one.
    let description: String

    /// Creates an error.
    ///
    /// - Parameter description: What's wrong.
    init(_ description: String) {
      self.description = description
    }
  }

  /// The result of grouping a file's imports.
  enum Outcome: Equatable {

    /// The file's text with its imports grouped, the same text when they already are.
    case grouped(String)

    /// The imports can't be grouped, because of the line, counted from 1, for the reason.
    case unsupported(line: Int, reason: String)
  }

  /// Groups the imports at the top of a Swift file.
  ///
  /// The imports are the ones after the file's leading comments and before its first other line, with the `#if` blocks
  /// that contain only imports, and after the `#if` lines that wrap the whole file, whose `#endif` lines end it. Those
  /// stay above the imports with a blank line after them, and their `#endif` lines get a blank line before them. Another
  /// `#if` before the imports, such as one around a platform's part of the file, starts the code, which leaves the file
  /// alone. A comment in an `#if` block of imports moves with the block, and a comment on an import's line moves with the
  /// import. A comment between imports, an `#if` block that imports modules of different groups, a line with more than
  /// an import and a comment, an import with a block comment that spans lines, or an import whose module is on another
  /// line, makes the imports unsupported, as the grouping doesn't know where it belongs.
  ///
  /// - Parameters:
  ///   - text: The file's text.
  ///   - config: The configuration.
  /// - Returns: The file's text with its imports grouped, or why they can't be.
  static func group(_ text: String, config: Config) -> Outcome {
    let lines = ImportGroups.lines(of: text)
    let texts = lines.map(\.text)

    var index = 0
    while index < lines.count, case .comment = lineKind(lines, at: index) {
      index += 1
    }
    var headerEnd = index
    while headerEnd > 0, isBlank(texts[headerEnd - 1]) {
      headerEnd -= 1
    }

    var wrappers: [String] = []
    var wrapperEnd: Int?
    var items: [Item] = []
    var codeStart = lines.count
    scan: while index < lines.count {
      let line = lines[index]
      if isBlank(line.text) {
        index += 1
      } else if isDirective(line, "#if") {
        switch importBlock(lines, from: index) {
        case .imports(let end, let modules):
          items.append(Item(lines: Array(texts[index ... end]), modules: modules, isBlock: true, line: index + 1))
          index = end + 1
        case .unsupported(let lineIndex, let reason):
          return .unsupported(line: lineIndex + 1, reason: reason)
        case .other:
          if items.isEmpty, let end = endOfBlock(lines, from: index), endsTheFile(lines, after: end) {
            // the lines of a block comment that the #if starts stay with it
            wrappers.append(line.text)
            while lines[index].endsInCommentOrString, index + 1 < lines.count, isBlank(lines[index + 1].code) {
              index += 1
              wrappers.append(texts[index])
            }
            wrapperEnd = end
            index += 1
          } else {
            codeStart = index
            break scan
          }
        }
      } else {
        switch lineKind(lines, at: index) {
        case .comment:
          if importFollows(lines, from: index + 1) {
            return .unsupported(line: index + 1, reason: "a comment between imports")
          } else {
            codeStart = index
            break scan
          }
        case .import(let module):
          items.append(Item(lines: [line.text], modules: [module], isBlock: false, line: index + 1))
          index += 1
        case .unsupportedImport(let reason):
          return .unsupported(line: index + 1, reason: reason)
        case .code:
          codeStart = index
          break scan
        }
      }
    }

    guard !items.isEmpty else {
      return .grouped(text)
    }

    var groups = Array(repeating: (blocks: [Item](), imports: [Item]()), count: config.groups.count)
    for item in items {
      let indices = Set(item.modules.map(config.group(of:)))
      guard indices.count == 1, let groupIndex = indices.first else {
        return .unsupported(line: item.line, reason: "an #if block that imports modules of different groups")
      }
      if item.isBlock {
        groups[groupIndex].blocks.append(item)
      } else {
        groups[groupIndex].imports.append(item)
      }
    }

    var output = Array(texts[0 ..< headerEnd])
    if !output.isEmpty {
      output.append("")
    }
    if !wrappers.isEmpty {
      output += wrappers
      output.append("")
    }
    var isFirstGroup = true
    for group in groups where !group.blocks.isEmpty || !group.imports.isEmpty {
      if !isFirstGroup {
        output.append("")
      }
      isFirstGroup = false

      // the blocks are ordered by the first module they import, so that the order doesn't depend on where they were
      let blocks = group.blocks.enumerated().sorted { lhs, rhs in
        let lhsModule = lhs.element.modules[0].lowercased()
        let rhsModule = rhs.element.modules[0].lowercased()
        return lhsModule == rhsModule ? lhs.offset < rhs.offset : lhsModule < rhsModule
      }
      for item in blocks.map(\.element) + group.imports {
        output += item.lines
      }
    }
    output.append("")

    // a file-wide #if has a blank line after it, so the #endif lines that end the file have one before them, for the two
    // ends to look alike
    var code = Array(texts[codeStart...])
    if let wrapperEnd, wrapperEnd > codeStart {
      let end = wrapperEnd - codeStart
      var blankStart = end
      while blankStart > 0, isBlank(code[blankStart - 1]) {
        blankStart -= 1
      }
      if blankStart > 0 {
        code.replaceSubrange(blankStart ..< end, with: [""])
      }
    }
    output += code
    return .grouped(output.joined(separator: "\n"))
  }

  /// Returns whether a file's imports are in the same groups as in its grouped text, whatever their order in a group,
  /// which SwiftFormat's `sortImports` checks.
  ///
  /// - Parameters:
  ///   - text: The file's text.
  ///   - grouped: The file's text with its imports grouped.
  /// - Returns: Whether the imports are in the same groups.
  static func hasSameGroups(_ text: String, as grouped: String) -> Bool {
    sortingRunsOfImports(text) == sortingRunsOfImports(grouped)
  }

  /// Returns the Swift files that a configuration applies to, relative to the repository, in order.
  ///
  /// The walk of a directory doesn't follow a symbolic link, so that a file is grouped where it is, when the paths have
  /// it, and doesn't go into a file or folder whose name starts with a dot, such as `.build`, where SwiftPM puts
  /// generated Swift files, or into an excluded one. A file listed in the paths is kept, whatever its name, when it's in
  /// the repository, and a directory that can't be read throws, so that its files aren't left out without a word.
  ///
  /// - Parameters:
  ///   - config: The configuration.
  ///   - repository: The repository, with its symbolic links resolved.
  /// - Returns: The files' paths.
  static func swiftFiles(config: Config, repository: URL) throws -> [String] {
    // the path of a file relative to the repository, with the symbolic links on its path resolved, as the repository's
    // are, `nil` for a file outside it
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
        throw ConfigError("\(path) doesn't exist")
      }

      var urls: [URL] = []
      if isDirectory.boolValue {
        var enumerationError: Error?
        let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.isSymbolicLinkKey], options: [], errorHandler: { _, error in
          enumerationError = error
          return false
        })
        guard let enumerator else {
          throw ConfigError("\(path) can't be read")
        }
        while let item = enumerator.nextObject() as? URL {
          // a skipped folder isn't walked, so that one that can't be read doesn't stop the run. the name is checked
          // rather than skipping hidden files, which on macOS also skips the files flagged as hidden
          let isLink = (try? item.resourceValues(forKeys: [.isSymbolicLinkKey]).isSymbolicLink) == true
          if isLink || item.lastPathComponent.hasPrefix(".") || relativePath(of: item).map(isExcluded) == true {
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

  // MARK: - Lines

  /// A line of a file, with its code.
  struct Line: Equatable {

    /// The line's text.
    let text: String

    /// The line's code: its text without its comments, with each of its literals standing for `""`, so that what's in
    /// them, such as a `//`, a `/*`, a `"""` or an `#endif`, isn't read as code. A line in a multiline string literal is
    /// code, as it's part of the literal.
    let code: String

    /// Whether the line starts in a block comment or a multiline string literal.
    let startsInCommentOrString: Bool

    /// Whether the line ends in a block comment or a multiline string literal.
    let endsInCommentOrString: Bool
  }

  /// Returns the lines of a file, read from its start, so that each line's code is read knowing the block comments and
  /// the multiline string literals that are open at its start.
  ///
  /// Block comments nest, as in Swift. A string literal can be raw, as in `#"a "quoted" word"#`, and multiline, and
  /// ends at its closing delimiter, which for a multiline string literal starts its line, so that an escaped `\"""` in
  /// it doesn't end it. A string literal's interpolations, as in `"\(name ?? "")"`, are read as code to their closing
  /// parenthesis, with the literals in them, which can be multiline. An extended regular expression literal, as in
  /// `#/a/*b/#`, ends on its line. A single-line string literal that doesn't end on its line is left there.
  ///
  /// - Parameter text: The file's text.
  /// - Returns: The file's lines.
  static func lines(of text: String) -> [Line] {
    var commentDepth = 0
    var contexts: [Context] = []
    var lines: [Line] = []
    for lineText in text.components(separatedBy: "\n") {
      let startsInString = contexts.contains(where: \.isMultilineString)
      let startsInCommentOrString = commentDepth > 0 || startsInString
      var code = startsInString ? Constants.literalCode : ""
      var rest = Substring(lineText)
      while let character = rest.first {
        if commentDepth > 0 {
          if rest.hasPrefix("/*") {
            commentDepth += 1
            rest = rest.dropFirst(2)
          } else if rest.hasPrefix("*/") {
            commentDepth -= 1
            rest = rest.dropFirst(2)
          } else {
            rest = rest.dropFirst()
          }
        } else if case .string(let hashes, let isMultiline)? = contexts.last {
          let closer = (isMultiline ? Constants.multilineStringDelimiter : "\"") + String(repeating: "#", count: hashes)
          let escape = "\\" + String(repeating: "#", count: hashes)
          if rest.hasPrefix(closer), !isMultiline || lineText[..<rest.startIndex].allSatisfy(\.isWhitespace) {
            contexts.removeLast()
            rest = rest.dropFirst(closer.count)
          } else if rest.hasPrefix(escape) {
            // an escape, as in `\"`, or an interpolation, as in `\(name)`, with as many `#` as the literal
            rest = rest.dropFirst(escape.count)
            if rest.first == "(" {
              contexts.append(.interpolation(parentheses: 0))
            }
            rest = rest.dropFirst()
          } else {
            rest = rest.dropFirst()
          }
        } else {
          // code, the file's or an interpolation's, of which only the file's is the line's code
          let isFileCode = contexts.isEmpty
          let hashes = rest.prefix(while: { $0 == "#" }).count
          let afterHashes = rest.dropFirst(hashes)
          if rest.hasPrefix("//") {
            break
          } else if rest.hasPrefix("/*") {
            commentDepth = 1
            code += isFileCode ? " " : ""
            rest = rest.dropFirst(2)
          } else if afterHashes.first == "\"" {
            let isMultiline = afterHashes.hasPrefix(Constants.multilineStringDelimiter)
            contexts.append(.string(hashes: hashes, isMultiline: isMultiline))
            code += isFileCode ? Constants.literalCode : ""
            rest = afterHashes.dropFirst(isMultiline ? Constants.multilineStringDelimiter.count : 1)
          } else if hashes > 0, afterHashes.first == "/" {
            let closer = "/" + String(repeating: "#", count: hashes)
            var literal = afterHashes.dropFirst()
            while !literal.isEmpty, !literal.hasPrefix(closer) {
              literal = literal.dropFirst()
            }
            code += isFileCode ? Constants.literalCode : ""
            rest = literal.dropFirst(closer.count)
          } else if case .interpolation(let parentheses)? = contexts.last {
            if character == "(" {
              contexts[contexts.count - 1] = .interpolation(parentheses: parentheses + 1)
            } else if character == ")" {
              if parentheses == 0 {
                contexts.removeLast()
              } else {
                contexts[contexts.count - 1] = .interpolation(parentheses: parentheses - 1)
              }
            }
            rest = rest.dropFirst()
          } else {
            code.append(character)
            rest = rest.dropFirst()
          }
        }
      }

      // a single-line string literal ends on its line, so one that doesn't is left there, with what's open in it
      if let index = contexts.firstIndex(where: \.isSingleLineString) {
        contexts.removeSubrange(index...)
      }
      let endsInCommentOrString = commentDepth > 0 || contexts.contains(where: \.isMultilineString)
      lines.append(Line(text: lineText, code: code, startsInCommentOrString: startsInCommentOrString, endsInCommentOrString: endsInCommentOrString))
    }
    return lines
  }

  // MARK: - Private

  /// A literal, or an interpolation in one, that's open at a point of a file.
  private enum Context {

    /// A string literal, with the number of `#` around it, and whether it's multiline.
    case string(hashes: Int, isMultiline: Bool)

    /// An interpolation in a string literal, with the number of parentheses open in it.
    case interpolation(parentheses: Int)

    /// Whether it's a multiline string literal.
    var isMultilineString: Bool {
      if case .string(_, true) = self {
        return true
      }
      return false
    }

    /// Whether it's a single-line string literal.
    var isSingleLineString: Bool {
      if case .string(_, false) = self {
        return true
      }
      return false
    }
  }

  /// An import, or an `#if` block of imports, at the top of a file.
  private struct Item {

    /// The lines of the import or the block.
    let lines: [String]

    /// The modules it imports.
    let modules: [String]

    /// Whether it's an `#if` block.
    let isBlock: Bool

    /// The line where it starts, counted from 1.
    let line: Int
  }

  /// What a line is, from its code.
  private enum LineKind {

    /// A blank line or comments.
    case comment

    /// An import of a module, with its submodules, such as `UIKit.UIGestureRecognizerSubclass`.
    case `import`(String)

    /// An import that can't be grouped, with why.
    case unsupportedImport(String)

    /// Code that isn't an import.
    case code
  }

  /// Returns what a line is, from its code.
  ///
  /// An import can't be grouped when it shares a line with a block comment that spans lines, as it can't move without
  /// the comment's other lines, and neither can a comment whose last line has an import, or a line of only attributes
  /// that an import follows.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - index: The index of the line.
  /// - Returns: What the line is.
  private static func lineKind(_ lines: [Line], at index: Int) -> LineKind {
    let line = lines[index]
    if isBlank(line.code) {
      // the comment's last line is the first line after it that ends outside it, or that has code
      if line.endsInCommentOrString,
         let end = lines[(index + 1)...].firstIndex(where: { !$0.endsInCommentOrString || !isBlank($0.code) }),
         restAfterImportKeyword(lines[end].code) != nil
      {
        return .unsupportedImport(Constants.importWithAMultilineCommentReason)
      }
      return .comment
    } else if let rest = restAfterImportKeyword(line.code) {
      if line.startsInCommentOrString || line.endsInCommentOrString {
        return .unsupportedImport(Constants.importWithAMultilineCommentReason)
      } else if let module = importedModule(after: rest) {
        return module.isEmpty ? .unsupportedImport(Constants.importWithoutItsModuleReason) : .import(module)
      } else {
        return .unsupportedImport(Constants.unreadableImportReason)
      }
    } else if restAfterAttributes(line.code)?.isEmpty == true,
              let next = lines[(index + 1)...].firstIndex(where: { !isBlank($0.code) }),
              restAfterImportKeyword(lines[next].code) != nil
    {
      // a line of only attributes is the start of the import that comes next, after comments
      return .unsupportedImport(Constants.importWithItsAttributesOnAnotherLineReason)
    } else {
      return .code
    }
  }

  /// Returns the module that an import imports, empty when the module isn't on the line, and `nil` when more code follows
  /// the module, such as a second import.
  ///
  /// - Parameter rest: The import's code after its `import` keyword, without its comments.
  /// - Returns: The module, with its submodules, such as `UIKit.UIGestureRecognizerSubclass`.
  private static func importedModule(after rest: Substring) -> String? {
    var rest = rest
    // a kind can end the line, as in `import struct`, whose module is on the next line
    for kind in Constants.importKinds where rest.hasPrefix(kind) && rest.dropFirst(kind.count).first.map(\.isWhitespace) ?? true {
      rest = rest.dropFirst(kind.count).drop(while: \.isWhitespace)
      break
    }

    var module = rest.prefix(while: isIdentifierCharacter)
    var tail = rest.dropFirst(module.count)
    while tail.first == ".", tail.dropFirst().first.map(isIdentifierCharacter) == true {
      let component = tail.dropFirst().prefix(while: isIdentifierCharacter)
      module = rest.prefix(module.count + 1 + component.count)
      tail = tail.dropFirst(1 + component.count)
    }
    guard tail.allSatisfy(\.isWhitespace) else {
      return nil
    }
    return String(module)
  }

  /// Returns the rest of the code of a line after its `import` keyword, `nil` for code that doesn't start with one after
  /// its attributes.
  ///
  /// - Parameter code: The code of the line, without its comments.
  /// - Returns: The rest of the code, without its leading whitespace.
  private static func restAfterImportKeyword(_ code: String) -> Substring? {
    // the keyword can end the line, when the module is on the next line
    guard let rest = restAfterAttributes(code), rest.hasPrefix("import"), rest.dropFirst("import".count).first.map(\.isWhitespace) ?? true else {
      return nil
    }
    return rest.dropFirst("import".count).drop(while: \.isWhitespace)
  }

  /// Returns the rest of the code of a line after its attributes, such as `@testable` or `@_spi(Private)`, `nil` when an
  /// attribute's arguments go on to the next line.
  ///
  /// - Parameter code: The code of the line, without its comments.
  /// - Returns: The rest of the code, without its leading whitespace.
  private static func restAfterAttributes(_ code: String) -> Substring? {
    var rest = code.drop(while: \.isWhitespace)
    while rest.first == "@" {
      rest = rest.dropFirst().drop(while: isIdentifierCharacter)
      if rest.first == "(" {
        guard let close = rest.firstIndex(of: ")") else {
          return nil
        }
        rest = rest[rest.index(after: close)...]
      }
      rest = rest.drop(while: \.isWhitespace)
    }
    return rest
  }

  /// What an `#if` block at the top of a file contains.
  private enum Block: Equatable {

    /// Imports and comments, with the index of the block's `#endif` and the modules it imports, without the ones in its
    /// comments.
    case imports(end: Int, modules: [String])

    /// A line that makes the imports unsupported, such as two imports on one line, with its index and why.
    case unsupported(lineIndex: Int, reason: String)

    /// Other lines, or no import.
    case other
  }

  /// Returns what the `#if` block at a line contains, which it reads to the block's `#endif` while the block has only
  /// imports and comments.
  ///
  /// The block moves whole, so a comment in it belongs to it, unlike a comment between imports. A directive that starts
  /// a block comment that goes on past its line makes a block of imports unsupported, as the comment can go on past the
  /// block, which can't move without it. A block of code with such a directive stays where it is, as any block of code.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - start: The index of the block's `#if`.
  /// - Returns: What the block contains.
  private static func importBlock(_ lines: [Line], from start: Int) -> Block {
    var depth = 0
    var modules: [String] = []
    // the first directive that starts a block comment that goes on past its line
    var multilineCommentDirective: Int?
    for index in start ..< lines.count {
      let line = lines[index]
      if ["#if", "#elseif", "#else", "#endif"].contains(where: { isDirective(line, $0) }) {
        if isDirective(line, "#if") {
          depth += 1
        } else if isDirective(line, "#endif") {
          depth -= 1
        }
        if line.endsInCommentOrString, multilineCommentDirective == nil {
          multilineCommentDirective = index
        }

        if depth == 0 {
          if modules.isEmpty {
            return .other
          } else if let multilineCommentDirective {
            return .unsupported(lineIndex: multilineCommentDirective, reason: Constants.directiveWithAMultilineCommentReason)
          } else {
            return .imports(end: index, modules: modules)
          }
        }
      } else {
        switch lineKind(lines, at: index) {
        case .comment:
          continue
        case .import(let module):
          modules.append(module)
        case .unsupportedImport(let reason):
          return .unsupported(lineIndex: index, reason: reason)
        case .code:
          return .other
        }
      }
    }
    return .other
  }

  /// Returns the index of the `#endif` of the `#if` block at a line, `nil` when the block doesn't end.
  ///
  /// A line that starts in a block comment or a multiline string literal isn't a directive, as an `#if` in them, such
  /// as in a template or a test's sample code, isn't the file's.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - start: The index of the block's `#if`.
  /// - Returns: The index of the block's `#endif`.
  private static func endOfBlock(_ lines: [Line], from start: Int) -> Int? {
    var depth = 0
    for index in start ..< lines.count {
      if isDirective(lines[index], "#if") {
        depth += 1
      } else if isDirective(lines[index], "#endif") {
        depth -= 1
        if depth == 0 {
          return index
        }
      }
    }
    return nil
  }

  /// Returns whether only blank lines, and the `#endif` lines of the blocks around a block, follow its `#endif` to the
  /// end of a file.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - index: The index of the block's `#endif`.
  /// - Returns: Whether the block's `#endif` ends the file.
  private static func endsTheFile(_ lines: [Line], after index: Int) -> Bool {
    lines[(index + 1)...].allSatisfy { isBlank($0.text) || isDirective($0.text, "#endif") }
  }

  /// Returns whether an import, read or not, or an `#if` block with one, comes first from a line on, after comments and
  /// blank lines.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - index: The index of the line.
  /// - Returns: Whether an import follows.
  private static func importFollows(_ lines: [Line], from index: Int) -> Bool {
    for next in index ..< lines.count {
      switch lineKind(lines, at: next) {
      case .comment:
        continue
      case .import,
           .unsupportedImport:
        return true
      case .code:
        return isDirective(lines[next], "#if") && importBlock(lines, from: next) != .other
      }
    }
    return false
  }

  /// Returns the lines of a text with each run of imports sorted.
  ///
  /// - Parameter text: The text.
  /// - Returns: The lines, with each run of consecutive import lines sorted.
  private static func sortingRunsOfImports(_ text: String) -> [String] {
    let lines = ImportGroups.lines(of: text)
    var texts = lines.map(\.text)
    var start = 0
    while start < lines.count {
      guard isImport(lines, at: start) else {
        start += 1
        continue
      }
      var end = start
      while end < lines.count, isImport(lines, at: end) {
        end += 1
      }
      texts[start ..< end].sort()
      start = end
    }
    return texts
  }

  /// Returns whether a line is a compiler directive, such as `#if` or `#endif`, from its code, so that a comment after the
  /// directive doesn't matter, and a line that starts in a block comment or a multiline string literal isn't one.
  ///
  /// - Parameters:
  ///   - line: The line.
  ///   - directive: The directive, such as `#if`.
  /// - Returns: Whether the line is the directive.
  private static func isDirective(_ line: Line, _ directive: String) -> Bool {
    !line.startsInCommentOrString && isDirective(line.code, directive)
  }

  /// Returns whether a text is a compiler directive, such as `#if` or `#endif`, with or without a condition.
  ///
  /// - Parameters:
  ///   - text: The text, such as a line.
  ///   - directive: The directive, such as `#if`.
  /// - Returns: Whether the text is the directive.
  private static func isDirective(_ text: String, _ directive: String) -> Bool {
    let trimmed = text.trimmingCharacters(in: .whitespaces)
    guard trimmed.hasPrefix(directive) else {
      return false
    }
    let next = trimmed.dropFirst(directive.count).first
    return next == nil || next == "(" || next?.isWhitespace == true
  }

  /// Returns whether a line is an import that can be grouped.
  ///
  /// - Parameters:
  ///   - lines: The file's lines.
  ///   - index: The index of the line.
  /// - Returns: Whether the line is an import.
  private static func isImport(_ lines: [Line], at index: Int) -> Bool {
    switch lineKind(lines, at: index) {
    case .import:
      return true
    case .comment,
         .unsupportedImport,
         .code:
      return false
    }
  }

  /// Returns whether a text is blank.
  ///
  /// - Parameter text: The text, such as a line.
  /// - Returns: Whether the text is blank.
  private static func isBlank(_ text: String) -> Bool {
    text.allSatisfy(\.isWhitespace)
  }

  /// Returns whether a character can be part of an identifier.
  ///
  /// - Parameter character: The character.
  /// - Returns: Whether the character can be part of an identifier.
  private static func isIdentifierCharacter(_ character: Character) -> Bool {
    character.isLetter || character.isNumber || character == "_"
  }

  // MARK: - Constants

  private enum Constants {

    /// The kinds of declaration that an import can import alone, as in `import struct Foundation.Date`.
    static let importKinds = ["typealias", "struct", "class", "enum", "protocol", "let", "var", "func"]

    /// Why an import that can't be read makes the imports unsupported.
    static let unreadableImportReason = "a line with more than an import and a comment"

    /// Why an import with a block comment that spans lines makes the imports unsupported, as the import can't move
    /// without the comment's other lines.
    static let importWithAMultilineCommentReason = "an import with a block comment that spans lines"

    /// Why an import whose module is on another line, as in `import` followed by a line with `UIKit`, makes the imports
    /// unsupported, as the import can't move without its module's line.
    static let importWithoutItsModuleReason = "an import whose module isn't on its line"

    /// Why an import whose attributes are on another line, as in a line with `@testable` followed by `import UIKit`,
    /// makes the imports unsupported, as the import can't move without its attributes' line.
    static let importWithItsAttributesOnAnotherLineReason = "an import whose attributes are on another line"

    /// Why a directive that starts a block comment that spans lines, in an `#if` block at the top of a file, makes the
    /// imports unsupported, as the block can't move without the comment's other lines.
    static let directiveWithAMultilineCommentReason = "a directive with a block comment that spans lines"

    /// The delimiter of a multiline string literal.
    static let multilineStringDelimiter = "\"\"\""

    /// What a literal stands for in a line's code.
    static let literalCode = "\"\""
  }
}

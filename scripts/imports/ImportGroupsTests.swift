//
//  ImportGroupsTests.swift
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

import ChouTiTest

class ImportGroupsTests: XCTestCase {

  // MARK: - Group

  func test_group_ordersTheGroups() {
    // given: a file whose imports are out of the groups' order, with a system import after the local module and
    // an #if block after the others
    let text = """
    //
    //  FileTests.swift
    //

    import ChouTiTest

    @testable import ComposeUI
    import ChouTi
    import SwiftUI

    #if canImport(UIKit)
    import UIKit
    #endif

    class FileTests: XCTestCase {}

    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the system frameworks come first, then the external frameworks, the test frameworks and the local modules,
    // with a blank line between the groups
    expect(outcome) == .grouped("""
    //
    //  FileTests.swift
    //

    #if canImport(UIKit)
    import UIKit
    #endif
    import SwiftUI

    import ChouTi

    import ChouTiTest

    @testable import ComposeUI

    class FileTests: XCTestCase {}

    """)
  }

  func test_group_systemGroup_putsTheIfBlocksFirst_inTheOrderOfTheirModules() {
    // given: a file whose system frameworks are in three groups, with the UIKit block before the AppKit block
    let text = """
    import QuartzCore

    #if canImport(UIKit)
    import UIKit
    #endif

    #if canImport(AppKit)
    import AppKit
    #endif

    import ChouTiTest

    @_spi(Private) @testable import ComposeUI

    class A {}
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the system frameworks are one group, with the AppKit block, the UIKit block, then the other imports
    expect(outcome) == .grouped("""
    #if canImport(AppKit)
    import AppKit
    #endif
    #if canImport(UIKit)
    import UIKit
    #endif
    import QuartzCore

    import ChouTiTest

    @_spi(Private) @testable import ComposeUI

    class A {}
    """)
  }

  func test_group_ifBlocksOfTheSameModule_keepTheirOrder() {
    // given: two #if blocks that import the same module, the tvOS block before the iOS block, after another import of
    // their group
    let text = """
    import Foundation
    #if os(tvOS)
    import UIKit
    #endif
    #if os(iOS)
    import UIKit
    #endif

    class A {}
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the blocks come first, in their order, as their module doesn't order them
    expect(outcome) == .grouped("""
    #if os(tvOS)
    import UIKit
    #endif
    #if os(iOS)
    import UIKit
    #endif
    import Foundation

    class A {}
    """)
  }

  func test_group_fileWideIf_staysAboveTheImports() {
    // given: a file in an #if block, whose imports start right after the #if
    let text = """
    #if canImport(AppKit)
    import ChouTiTest
    import AppKit

    import ComposeUI

    class A {}
    #endif
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the #if stays above the imports, with a blank line after it, and its #endif has a blank line before it
    expect(outcome) == .grouped("""
    #if canImport(AppKit)

    import AppKit

    import ChouTiTest

    import ComposeUI

    class A {}

    #endif
    """)
  }

  func test_group_nestedFileWideIfs_haveOneBlankLineBeforeTheirEndifs() {
    // given: a file in two #if blocks, with three blank lines before their #endif lines
    let text = """
    #if canImport(UIKit)
    #if !os(tvOS)
    import UIKit

    class A {}



    #endif
    #endif

    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the #if lines stay together above the imports, and one blank line comes before the #endif lines
    expect(outcome) == .grouped("""
    #if canImport(UIKit)
    #if !os(tvOS)

    import UIKit

    class A {}

    #endif
    #endif

    """)
  }

  func test_group_platformSections_areLeftAlone() {
    // given: a file with a part for each platform, each in an #if block with its own imports
    let text = """
    #if canImport(AppKit)
    import AppKit

    class A {}
    #endif

    #if canImport(UIKit)
    import UIKit

    class A {}
    #endif
    """

    // then: the first #if doesn't wrap the file, so it starts the code, and the file stays as it is
    expect(ImportGroups.group(text, config: Constants.config)) == .grouped(text)
  }

  func test_group_ifWithoutItsEndif_isLeftAlone() {
    // given: a file in an #if block whose #endif is missing, with imports of different groups
    let text = """
    #if canImport(UIKit)
    import UIKit
    import ChouTiTest
    """

    // then: the #if is neither a file-wide #if nor a block of imports, so it starts the code, and the file stays as it is
    expect(ImportGroups.group(text, config: Constants.config)) == .grouped(text)
  }

  func test_group_fileWideIf_withDirectivesInACommentAndAString_endsAtItsEndif() {
    // given: a file in an #if block, with an #endif in a block comment, an #if in a multiline string literal, and an
    // #endif in a block comment with code after it
    let text = #"""
    #if canImport(UIKit)
    import UIKit

    /*
     #endif
     */
    let sample = """
    #if DEBUG
    """
    /* the end:
     #endif
     */ let end = 1
    #endif
    """#

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the directives in the comments and the string aren't the file's, so the #if wraps the file, with a blank
    // line after it and one before its #endif
    expect(outcome) == .grouped(#"""
    #if canImport(UIKit)

    import UIKit

    /*
     #endif
     */
    let sample = """
    #if DEBUG
    """
    /* the end:
     #endif
     */ let end = 1

    #endif
    """#)
  }

  func test_group_attributesSubmodulesAndDeclarations_goWithTheirModules() {
    // given: imports with attributes, of a submodule and of a declaration
    let text = """
    @_spi(Private) @testable import ComposeUI
    import ChouTiTest
    import UIKit.UIGestureRecognizerSubclass
    import struct Foundation.Date
    @preconcurrency import Combine

    class A {}
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: each goes with its module, and the system imports keep their order, which SwiftFormat sorts
    expect(outcome) == .grouped("""
    import UIKit.UIGestureRecognizerSubclass
    import struct Foundation.Date
    @preconcurrency import Combine

    import ChouTiTest

    @_spi(Private) @testable import ComposeUI

    class A {}
    """)
  }

  func test_group_codeAfterTheImports_isLeftAlone() {
    // given: an #if block of code, one after a comment, one with only a comment, an attribute of a declaration, one
    // whose arguments go on to the next lines, and a declaration after a block comment on its line, right after the
    // imports
    let ifBlock = """
    @testable import ComposeUI

    #if DEBUG
    /// The checks.
    enum Checks {}
    #endif
    """
    let ifBlockAfterAComment = """
    import ChouTiTest

    // the checks
    #if DEBUG
    enum Checks {}
    #endif
    """
    let ifBlockWithAComment = """
    import ChouTiTest

    #if DEBUG
    // the checks
    #endif
    """
    let attribute = """
    import ChouTiTest

    @MainActor
    final class A {}
    """
    let attributeOnLines = """
    import ChouTiTest

    @available(
      *, deprecated
    )
    final class A {}
    """
    let blockComment = """
    import ChouTiTest

    /* the type */ final class A {}
    """

    // then: none is an import, so the files stay as they are
    expect(ImportGroups.group(ifBlock, config: Constants.config)) == .grouped(ifBlock)
    expect(ImportGroups.group(ifBlockAfterAComment, config: Constants.config)) == .grouped(ifBlockAfterAComment)
    expect(ImportGroups.group(ifBlockWithAComment, config: Constants.config)) == .grouped(ifBlockWithAComment)
    expect(ImportGroups.group(attribute, config: Constants.config)) == .grouped(attribute)
    expect(ImportGroups.group(attributeOnLines, config: Constants.config)) == .grouped(attributeOnLines)
    expect(ImportGroups.group(blockComment, config: Constants.config)) == .grouped(blockComment)
  }

  func test_group_withoutImports_isUnchanged() {
    // given: a file without imports, and a file in an #if block without imports
    let withoutImports = """
    //
    //  A.swift
    //

    /// A type.
    enum A {}
    """
    let ifBlockWithoutImports = """
    #if DEBUG
    enum A {}
    #endif
    """

    // then: they stay as they are
    expect(ImportGroups.group(withoutImports, config: Constants.config)) == .grouped(withoutImports)
    expect(ImportGroups.group(ifBlockWithoutImports, config: Constants.config)) == .grouped(ifBlockWithoutImports)
  }

  func test_group_blankLines_areOneBetweenGroups() {
    // given: imports with two blank lines between them and three before the code, and a comment after an import
    let text = """
    import ChouTiTest


    import UIKit // for the views



    class A {}
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: one blank line separates the groups and the code, and the comment stays with its import
    expect(outcome) == .grouped("""
    import UIKit // for the views

    import ChouTiTest

    class A {}
    """)
  }

  func test_group_ifBlockWithBranches_staysWhole() {
    // given: an #if block of imports with an #elseif branch, after a test framework
    let text = """
    import ChouTiTest
    #if canImport(AppKit)
    import AppKit
    #elseif canImport(UIKit)
    import UIKit
    #endif

    class A {}
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the block moves whole to the system group
    expect(outcome) == .grouped("""
    #if canImport(AppKit)
    import AppKit
    #elseif canImport(UIKit)
    import UIKit
    #endif

    import ChouTiTest

    class A {}
    """)
  }

  func test_group_ifBlockWithAComment_movesWhole() {
    // given: an #if block of imports with a comment in it, between an external framework and a system framework
    let text = """
    import ChouTi
    #if canImport(UIKit)
    // for the gesture recognizer's subclass hooks
    import UIKit.UIGestureRecognizerSubclass
    #endif
    import Foundation

    let x = 1
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the block moves whole, with its comment, to the system group
    expect(outcome) == .grouped("""
    #if canImport(UIKit)
    // for the gesture recognizer's subclass hooks
    import UIKit.UIGestureRecognizerSubclass
    #endif
    import Foundation

    import ChouTi

    let x = 1
    """)
  }

  func test_group_ifBlockWithAnImportInABlockComment_goesWithItsImports() {
    // given: an #if block with a test framework's import in a block comment and a system framework's import, after an
    // external framework
    let text = """
    import ChouTi
    #if canImport(UIKit)
    /*
     import ChouTiTest
     */
    import UIKit
    #endif

    let x = 1
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the import in the comment doesn't count, so the block goes to the system group
    expect(outcome) == .grouped("""
    #if canImport(UIKit)
    /*
     import ChouTiTest
     */
    import UIKit
    #endif

    import ChouTi

    let x = 1
    """)
  }

  func test_group_blockCommentAfterAnImport_staysWithIt() {
    // given: an external framework with a block comment after it, before a system framework
    let text = """
    import ChouTi /* the helpers */
    import Foundation

    let x = 1
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the comment stays with its import
    expect(outcome) == .grouped("""
    import Foundation

    import ChouTi /* the helpers */

    let x = 1
    """)
  }

  func test_group_commentsOnAnImportsLine_moveWithIt() {
    // given: a local module's import with a comment between its attribute and its keyword, before system frameworks'
    // imports with comments on their lines: a block comment before the import, two, a nested one, and one in place of
    // the space before the module, and an #if block with an import after a block comment
    let text = """
    @testable /* for the internals */ import ComposeUI
    /* the views */ import UIKit
    /* the layers */ /* and more */ import QuartzCore
    /* the store /* of data */ */ import CoreData
    import/* the basics */Foundation
    #if canImport(AppKit)
    /* the views */ import AppKit
    #endif

    let x = 1
    """

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: each import goes in its module's group, with the comments on its line
    expect(outcome) == .grouped("""
    #if canImport(AppKit)
    /* the views */ import AppKit
    #endif
    /* the views */ import UIKit
    /* the layers */ /* and more */ import QuartzCore
    /* the store /* of data */ */ import CoreData
    import/* the basics */Foundation

    @testable /* for the internals */ import ComposeUI

    let x = 1
    """)
  }

  func test_group_fileWideIf_withQuotesInAComment_endsAtItsEndif() {
    // given: a file in an #if block, with three quotes in a documentation comment
    let text = #"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    /// Use """ for a multiline string.
    let x = 1
    #endif
    """#

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the quotes in the comment don't open a string, so the #if wraps the file, and the imports are grouped
    expect(outcome) == .grouped(#"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    /// Use """ for a multiline string.
    let x = 1

    #endif
    """#)
  }

  func test_group_fileWideIf_withQuotesAfterCode_endsAtItsEndif() {
    // given: a file in an #if block, with three quotes in a comment after code, a multiline string literal after a
    // string literal with `//` in it, and one after a block comment, both with an #endif in them
    let text = #"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    let x = 1 // use """ for a multiline string
    let url = "https://example.com" + """
    #endif
    """
    /* the sample */ let sample = """
    #endif
    """
    #endif
    """#

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the quotes in the comment don't open a string, the strings' #endif lines aren't the file's, so the #if wraps
    // the file, and the imports are grouped
    expect(outcome) == .grouped(#"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    let x = 1 // use """ for a multiline string
    let url = "https://example.com" + """
    #endif
    """
    /* the sample */ let sample = """
    #endif
    """

    #endif
    """#)
  }

  func test_group_fileWideIf_withRawLiterals_endsAtItsEndif() {
    // given: a file in an #if block, with raw string literals that have a quote before a `/*` and three quotes, and an
    // extended regular expression literal with a `/*`
    let text = ##"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    let pattern = #"a "/*" b"#
    let glob = #"--include "**/*.swift""#
    let quotes = #"use """ here"#
    let regex = #/a/*b/#
    #endif
    """##

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: what's in the literals isn't a comment or a multiline string literal, so the #if wraps the file, and the
    // imports are grouped
    expect(outcome) == .grouped(##"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    let pattern = #"a "/*" b"#
    let glob = #"--include "**/*.swift""#
    let quotes = #"use """ here"#
    let regex = #/a/*b/#

    #endif
    """##)
  }

  func test_group_fileWideIf_withStringsInInterpolations_endsAtItsEndif() {
    // given: a file in an #if block, with string literals in interpolations, in a call in one, and in a raw string's
    let text = ##"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    let title = "\(name ?? "")"
    let nested = "\(f("a", g("")))"
    let raw = #"\#(name ?? "")"#
    #endif
    """##

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: each literal ends after its interpolations, so the #if wraps the file, and the imports are grouped
    expect(outcome) == .grouped(##"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    let title = "\(name ?? "")"
    let nested = "\(f("a", g("")))"
    let raw = #"\#(name ?? "")"#

    #endif
    """##)
  }

  func test_group_fileWideIf_withEscapedDelimitersInAMultilineString_endsAtItsEndif() {
    // given: a file in an #if block, with a multiline string literal whose sample escapes its own `"""`, with an #endif
    let text = ##"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    let sample = """
      let s = \"""
      #endif
      \"""
      """
    #endif
    """##

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: the literal ends at its closing delimiter, which starts its line, so the #if wraps the file, and the imports
    // are grouped
    expect(outcome) == .grouped(##"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    let sample = """
      let s = \"""
      #endif
      \"""
      """

    #endif
    """##)
  }

  func test_group_fileWideIf_withARawMultilineString_endsAtItsEndif() {
    // given: a file in an #if block, with a raw multiline string literal that has a multiline string literal in it, with
    // an #endif, and a multiline string literal that closes on the line where another opens
    let text = ##"""
    #if canImport(UIKit)
    import ChouTiTest
    import UIKit

    let sample = #"""
      let s = """
      #endif
      """
      """#
    let pair = """
      a
      """ + """
      #endif
      """
    #endif
    """##

    // when: grouping its imports
    let outcome = ImportGroups.group(text, config: Constants.config)

    // then: each string ends at its own closing delimiter, so the #if wraps the file, and the imports are grouped
    expect(outcome) == .grouped(##"""
    #if canImport(UIKit)

    import UIKit

    import ChouTiTest

    let sample = #"""
      let s = """
      #endif
      """
      """#
    let pair = """
      a
      """ + """
      #endif
      """

    #endif
    """##)
  }

  func test_group_groupedText_isUnchanged() {
    // given: files whose imports are out of order
    let texts = [
      "import ChouTiTest\nimport UIKit\n\nclass A {}\n",
      "#if canImport(UIKit)\nimport ChouTiTest\n#if canImport(SwiftUI)\nimport SwiftUI\n#endif\n\nclass A {}\n#endif\n",
      "@testable import ComposeUI\nimport ChouTi\n",
    ]

    for text in texts {
      // when: grouping the imports, then grouping the grouped imports
      let grouped: String
      switch ImportGroups.group(text, config: Constants.config) {
      case .grouped(let text):
        grouped = text
      case .unsupported(let line, let reason):
        fail("expected the imports to be grouped, unsupported at line \(line): \(reason)")
        continue
      }

      // then: grouping them again changes nothing
      expect(ImportGroups.group(grouped, config: Constants.config), text) == .grouped(grouped)
    }
  }

  func test_group_commentBetweenImports_isUnsupported() {
    // given: a comment between two imports, one with a blank line after it, one before an #if block of imports, a
    // comment between a file-wide #if and its imports, and a comment before a line with two imports
    let betweenImports = """
    import ChouTiTest
    // the views
    import UIKit

    class A {}
    """
    let withABlankLineAfterIt = """
    import ChouTiTest
    // the views

    import UIKit

    class A {}
    """
    let beforeAnIfBlock = """
    import ChouTiTest
    // the views
    #if canImport(UIKit)
    import UIKit
    #endif

    class A {}
    """
    let afterTheIf = """
    #if canImport(UIKit)
    // the views
    import UIKit

    class A {}
    #endif
    """
    let beforeTwoImports = """
    import ComposeUI
    // the helpers
    import ChouTi; import ChouTiTest

    let x = 1
    """

    // then: the imports can't be grouped, as the comment's place is unknown
    expect(ImportGroups.group(betweenImports, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
    expect(ImportGroups.group(withABlankLineAfterIt, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
    expect(ImportGroups.group(beforeAnIfBlock, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
    expect(ImportGroups.group(afterTheIf, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
    expect(ImportGroups.group(beforeTwoImports, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
  }

  func test_group_blockComments_areLeftAlone() {
    // given: a template in a block comment, whose imports are out of the groups' order, a block comment between the
    // imports and the code, and a block comment that doesn't end, with an import in it, after the imports
    let template = """
    /// A template.

    /**

     import ComposeUI

     #if canImport(UIKit)
     import UIKit
     #endif

     public struct A {}
     */
    """
    let afterTheImports = """
    import ChouTiTest
    import UIKit

    /*
     The views.
     */
    class A {}
    """
    let unended = """
    import UIKit

    import ChouTiTest

    /* the old imports:
    import Foundation
    """

    // then: the template stays as it is, the block comment stays with the code, and the one that doesn't end goes on
    // to the end of the file, with its import
    expect(ImportGroups.group(template, config: Constants.config)) == .grouped(template)
    expect(ImportGroups.group(unended, config: Constants.config)) == .grouped(unended)
    expect(ImportGroups.group(afterTheImports, config: Constants.config)) == .grouped("""
    import UIKit

    import ChouTiTest

    /*
     The views.
     */
    class A {}
    """)
  }

  func test_group_blockCommentBetweenImports_isUnsupported() {
    // given: a block comment between two imports
    let text = """
    import ChouTiTest
    /*
     The views.
     */
    import UIKit

    class A {}
    """

    // then: the imports can't be grouped, as the comment's place is unknown
    expect(ImportGroups.group(text, config: Constants.config)) == .unsupported(line: 2, reason: "a comment between imports")
  }

  func test_group_lineWithMoreThanAnImport_isUnsupported() {
    // given: two imports on the first line, an import and a declaration on the line after an import, and two imports
    // with a block comment between them
    let twoImports = """
    import ChouTi; import ChouTiTest
    import Foundation

    let x = 1
    """
    let importAndCode = """
    import Foundation
    import ChouTi; let x = 1
    """
    let blockCommentBetween = """
    import Foundation
    import ChouTi /* the helpers */; import ChouTiTest
    """

    // then: the imports can't be grouped, as the things on a line can belong in different places
    expect(ImportGroups.group(twoImports, config: Constants.config)) == .unsupported(line: 1, reason: "a line with more than an import and a comment")
    expect(ImportGroups.group(importAndCode, config: Constants.config)) == .unsupported(line: 2, reason: "a line with more than an import and a comment")
    expect(ImportGroups.group(blockCommentBetween, config: Constants.config)) == .unsupported(line: 2, reason: "a line with more than an import and a comment")
  }

  func test_group_lineWithMoreThanAnImport_inAnIfBlock_isUnsupported() {
    // given: an #if block with two imports on a line, before other imports
    let twoImports = """
    #if canImport(UIKit)
    import UIKit; import SwiftUI
    #endif
    import ComposeUI
    import Foundation

    let x = 1
    """

    // then: the imports can't be grouped, as for a line outside an #if block
    expect(ImportGroups.group(twoImports, config: Constants.config)) == .unsupported(line: 2, reason: "a line with more than an import and a comment")
  }

  func test_group_importWithAMultilineBlockComment_isUnsupported() {
    // given: an import on the last line of a block comment that starts on an earlier line, an import whose block
    // comment goes on to the next line, and the same in an #if block before another import
    let commentBefore = """
    import ComposeUI
    /* the views,
     and more */ import UIKit

    let x = 1
    """
    let commentAfter = """
    import ComposeUI
    import UIKit /* the views,
     and more */

    let x = 1
    """
    let inAnIfBlock = """
    import ComposeUI
    #if canImport(UIKit)
    import UIKit /* the views,
     and more */
    #endif
    import Foundation

    let x = 1
    """

    // then: the imports can't be grouped, as the import can't move without the comment's other lines
    expect(ImportGroups.group(commentBefore, config: Constants.config)) == .unsupported(line: 2, reason: "an import with a block comment that spans lines")
    expect(ImportGroups.group(commentAfter, config: Constants.config)) == .unsupported(line: 2, reason: "an import with a block comment that spans lines")
    expect(ImportGroups.group(inAnIfBlock, config: Constants.config)) == .unsupported(line: 3, reason: "an import with a block comment that spans lines")
  }

  func test_group_importWithItsModuleOnTheNextLine_isUnsupported() {
    // given: imports whose modules are on the next line, which compile: after the keyword, after the keyword and a
    // space, and after the kind of a declaration
    let keyword = """
    import ComposeUI
    import
      UIKit

    let x = 1
    """
    let keywordAndASpace = "import ComposeUI\nimport \n  UIKit\n\nlet x = 1"
    let declaration = """
    import ComposeUI
    import struct
      Foundation.Date

    let x = 1
    """

    // then: the imports can't be grouped, as the import can't move without its module's line
    expect(ImportGroups.group(keyword, config: Constants.config)) == .unsupported(line: 2, reason: "an import whose module isn't on its line")
    expect(ImportGroups.group(keywordAndASpace, config: Constants.config)) == .unsupported(line: 2, reason: "an import whose module isn't on its line")
    expect(ImportGroups.group(declaration, config: Constants.config)) == .unsupported(line: 2, reason: "an import whose module isn't on its line")
  }

  func test_group_ifBlockOfModulesOfDifferentGroups_isUnsupported() {
    // given: an #if block that imports a system framework and a test framework
    let text = """
    import ComposeUI

    #if canImport(UIKit)
    import UIKit
    import ChouTiTest
    #endif

    class A {}
    """

    // then: the imports can't be grouped, as the block belongs in two groups
    expect(ImportGroups.group(text, config: Constants.config)) == .unsupported(line: 3, reason: "an #if block that imports modules of different groups")
  }

  func test_group_directiveWithAMultilineBlockComment_isUnsupported() {
    // given: an #if block of imports whose #endif starts a block comment that goes on to the next line, one whose #if
    // does, both after another import, and one whose #endif has a block comment that ends on its line
    let onTheEndif = """
    import Foundation
    #if canImport(Dispatch)
    import Dispatch
    #endif /* for the queues,
     and more */

    let x = Date()
    """
    let onTheIf = """
    import Foundation
    #if canImport(Dispatch) /* for the queues,
     and more */
    import Dispatch
    #endif

    let x = Date()
    """
    let importAfterTheComment = """
    import Foundation
    #if canImport(Dispatch) /* for the queues,
     and more */ import Dispatch
    #endif

    let x = Date()
    """
    let onOneLine = """
    import Foundation
    #if canImport(Dispatch)
    import Dispatch
    #endif /* for the queues */

    let x = Date()
    """

    // then: the imports can't be grouped when the comment goes on, as the block can't move without the comment's other
    // lines, and the block with the comment that ends on its line moves with it
    expect(ImportGroups.group(onTheEndif, config: Constants.config)) == .unsupported(line: 4, reason: "a directive with a block comment that spans lines")
    expect(ImportGroups.group(onTheIf, config: Constants.config)) == .unsupported(line: 2, reason: "a directive with a block comment that spans lines")
    expect(ImportGroups.group(importAfterTheComment, config: Constants.config)) == .unsupported(line: 2, reason: "a directive with a block comment that spans lines")
    expect(ImportGroups.group(onOneLine, config: Constants.config)) == .grouped("""
    #if canImport(Dispatch)
    import Dispatch
    #endif /* for the queues */
    import Foundation

    let x = Date()
    """)
  }

  func test_group_directiveWithAMultilineBlockComment_inAnIfBlockOfCode_isLeftAlone() {
    // given: imports before an #if block of code whose #if starts a block comment that goes on to the next line, the same
    // after a comment, and a file in an #if block whose #if does
    let afterTheImports = """
    import ChouTiTest
    import UIKit

    #if DEBUG /* remove once
     the bug is fixed */
    let debug = true
    #endif
    """
    let afterAComment = """
    import UIKit

    // the debug flag
    #if DEBUG /* remove once
     the bug is fixed */
    let debug = true
    #endif
    """
    let fileWide = """
    #if canImport(UIKit) /* the whole file,
     on UIKit */
    import UIKit

    class A {}
    #endif
    """

    // then: the #if blocks of code start the code, so the imports before them are grouped, and the file in the #if block
    // stays as it is
    expect(ImportGroups.group(afterTheImports, config: Constants.config)) == .grouped("""
    import UIKit

    import ChouTiTest

    #if DEBUG /* remove once
     the bug is fixed */
    let debug = true
    #endif
    """)
    expect(ImportGroups.group(afterAComment, config: Constants.config)) == .grouped(afterAComment)
    expect(ImportGroups.group(fileWide, config: Constants.config)) == .grouped(fileWide)
  }

  // MARK: - Same Groups

  func test_hasSameGroups() {
    // given: grouped imports
    let grouped = """
    import QuartzCore
    import UIKit

    import ChouTiTest

    class A {}
    """

    // then: imports in another order in a group are in the same groups, and an import in another group isn't
    expect(ImportGroups.hasSameGroups("import UIKit\nimport QuartzCore\n\nimport ChouTiTest\n\nclass A {}", as: grouped)) == true
    expect(ImportGroups.hasSameGroups("import QuartzCore\n\nimport ChouTiTest\nimport UIKit\n\nclass A {}", as: grouped)) == false
  }

  // MARK: - Swift Files

  func test_swiftFiles_leavesOutDotFoldersExcludedFoldersAndOutsideLinks() throws {
    // given: a repository with a Swift file and a text file in its sources, a Swift file in a dot folder and in an
    // excluded folder, an unreadable folder in each, a dot file, a dot folder and that dot file listed in the paths, and
    // a symbolic link to a Swift file outside the repository
    let repository = try makeDirectory()
    try write("let a = 1", to: "Sources/A.swift", in: repository)
    try write("a", to: "Sources/A.txt", in: repository)
    try write("let b = 1", to: "Sources/.build/Generated.swift", in: repository)
    try write("let c = 1", to: "Sources/.build/locked/Locked.swift", in: repository)
    try write("let d = 1", to: "Sources/Excluded/Excluded.swift", in: repository)
    try write("let e = 1", to: "Sources/Excluded/locked/Locked.swift", in: repository)
    try write("let f = 1", to: "Sources/.hidden.swift", in: repository)
    try write("let g = 1", to: ".github/G.swift", in: repository)
    let outside = try makeDirectory()
    try write("let h = 1", to: "Outside.swift", in: outside)
    try FileManager.default.createSymbolicLink(
      at: repository.appendingPathComponent("Sources/Link.swift"),
      withDestinationURL: outside.appendingPathComponent("Outside.swift")
    )
    try lock("Sources/.build/locked", in: repository)
    try lock("Sources/Excluded/locked", in: repository)
    let config = try ImportGroups.Config(parsing: """
    paths: Sources .github Sources/.hidden.swift
    exclude: Sources/Excluded
    group: *
    """)

    // when: listing its Swift files
    let files = try ImportGroups.swiftFiles(config: config, repository: repository)

    // then: the walk goes into neither the dot folder nor the excluded folder, so their unreadable folders don't throw,
    // leaves out the dot file and the link, and keeps the paths it's given, whatever their names
    expect(files) == [".github/G.swift", "Sources/.hidden.swift", "Sources/A.swift"]
  }

  func test_swiftFiles_unreadableFolder_throws() throws {
    // given: a repository with an unreadable folder in its paths
    let repository = try makeDirectory()
    try write("let a = 1", to: "Sources/locked/A.swift", in: repository)
    try lock("Sources/locked", in: repository)
    if FileManager.default.isReadableFile(atPath: repository.appendingPathComponent("Sources/locked").path) {
      try skip("the locked folder can be read, as by the root user")
    }
    let config = try ImportGroups.Config(parsing: "paths: Sources\ngroup: *")

    // then: listing its Swift files throws, instead of leaving out the folder's files
    expect(try ImportGroups.swiftFiles(config: config, repository: repository)).to(throwAnError())
  }

  func test_swiftFiles_missingPath_throws() throws {
    // given: a configuration whose path isn't in the repository
    let repository = try makeDirectory()
    let config = try ImportGroups.Config(parsing: "paths: Sources\ngroup: *")

    // then: listing the Swift files throws an error that names the path
    expect(try ImportGroups.swiftFiles(config: config, repository: repository)).to(throwError(ImportGroups.ConfigError("Sources doesn't exist")))
  }

  func test_swiftFiles_pathsWithADotOrASlash() throws {
    // given: a repository with a Swift file and two folders of them, and a configuration whose path ends with a slash,
    // and whose excluded folders start with `./` or end with a slash
    let repository = try makeDirectory()
    try write("let a = 1", to: "Sources/A.swift", in: repository)
    try write("let b = 1", to: "Sources/Generated/Generated.swift", in: repository)
    try write("let c = 1", to: "Sources/Vendor/Vendor.swift", in: repository)
    let config = try ImportGroups.Config(parsing: "paths: Sources/\nexclude: Sources/Generated/ ./Sources/Vendor\ngroup: *")

    // when: listing its Swift files
    let files = try ImportGroups.swiftFiles(config: config, repository: repository)

    // then: the excluded folders are left out
    expect(files) == ["Sources/A.swift"]
  }

  // MARK: - Config

  func test_config_normalizesThePaths() throws {
    // given: a configuration whose paths start with `./`, end with a slash or have two slashes in a row
    let text = """
    paths: ./Sources/ Tests//Unit
    exclude: ./Sources/Generated/
    group: *
    """

    // when: parsing it
    let config = try ImportGroups.Config(parsing: text)

    // then: the paths are in the form of the paths relative to the repository that they're compared with
    expect(config.paths) == ["Sources", "Tests/Unit"]
    expect(config.excludedPaths) == ["Sources/Generated"]
  }

  func test_config_parsing() throws {
    // given: a configuration with comments, two lines of paths and an excluded path
    let text = """
    # the test targets
    paths: Tests HostedTests
    paths: More # more tests
    exclude: Tests/_Deprecated

    group: *
    group: ChouTi
    group: ChouTiTest  XCTest
    group: ComposeUI
    """

    // when: parsing it
    let config = try ImportGroups.Config(parsing: text)

    // then: it has the paths, the excluded path and the groups in order, with the first for the other modules
    expect(config) == ImportGroups.Config(
      groups: [[], ["ChouTi"], ["ChouTiTest", "XCTest"], ["ComposeUI"]],
      otherModulesGroup: 0,
      paths: ["Tests", "HostedTests", "More"],
      excludedPaths: ["Tests/_Deprecated"]
    )
  }

  func test_config_parsing_errors() {
    // then: each mistake throws an error that names it
    let cases: [(text: String, error: String)] = [
      ("paths: Tests\ngroup ChouTi", "line 2: expected a key and its values, as `key: values`"),
      ("paths: Tests\ngroup: *\ngroup: *", "line 3: a second group for the modules that no group lists"),
      ("paths: Tests\ngroup:", "line 2: a group lists its modules, or is `*` alone"),
      ("paths: Tests\ngroup: ChouTi *", "line 2: a group lists its modules, or is `*` alone"),
      ("paths: Tests\ngroup: ChouTi\ngroup: ChouTi", "line 3: ChouTi is in two groups"),
      ("paths: Tests\norder: ChouTi", "line 2: unknown key `order`"),
      ("paths: Tests\ngroup: ChouTi", "no `group: *` for the modules that no group lists"),
      ("group: *", "no `paths` to apply the groups to"),
    ]
    for (text, error) in cases {
      expect(try ImportGroups.Config(parsing: text), text).to(throwError(ImportGroups.ConfigError(error)))
    }
  }

  func test_config_groupOfAModule() {
    // then: a listed module goes in its group, a submodule with its module, and another module in the group for them
    expect(Constants.config.group(of: "ChouTiTest")) == 2
    expect(Constants.config.group(of: "ComposeUI")) == 3
    expect(Constants.config.group(of: "UIKit.UIGestureRecognizerSubclass")) == 0
    expect(Constants.config.group(of: "QuartzCore")) == 0
  }

  // MARK: - Helpers

  /// Returns a new empty directory, with its symbolic links resolved, which is removed when the test ends.
  ///
  /// - Returns: The directory's URL.
  private func makeDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory.appendingPathComponent("ImportGroupsTests-\(UUID().uuidString)")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    addTeardownBlock {
      try? FileManager.default.removeItem(at: url)
    }
    return url.resolvingSymlinksInPath()
  }

  /// Writes a text to a file in a directory, with the folders on its path.
  ///
  /// - Parameters:
  ///   - text: The text.
  ///   - path: The file's path, relative to the directory.
  ///   - directory: The directory.
  private func write(_ text: String, to path: String, in directory: URL) throws {
    let url = directory.appendingPathComponent(path)
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try text.write(to: url, atomically: true, encoding: .utf8)
  }

  /// Makes a folder in a directory unreadable until the test ends, when it's made readable again so it can be removed.
  ///
  /// - Parameters:
  ///   - path: The folder's path, relative to the directory.
  ///   - directory: The directory.
  private func lock(_ path: String, in directory: URL) throws {
    let path = directory.appendingPathComponent(path).path
    try FileManager.default.setAttributes([.posixPermissions: 0], ofItemAtPath: path)
    // teardown blocks run in reverse order, so this runs before the directory is removed
    addTeardownBlock {
      try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: path)
    }
  }

  // MARK: - Constants

  private enum Constants {

    /// The groups: system frameworks, external frameworks, test frameworks and local modules.
    static let config = ImportGroups.Config(
      groups: [[], ["ChouTi"], ["ChouTiTest", "XCTest"], ["ComposeUI"]],
      otherModulesGroup: 0,
      paths: ["Tests"],
      excludedPaths: []
    )
  }
}

//
//  NSAttributedStringBuilder.swift
//  ChouTi
//
//  Created by Honghao Zhang on 10/25/22.
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

/// Build into `NSAttributedString` array.
public typealias NSAttributedStringArrayBuilder = ArrayBuilder<NSMutableAttributedStringConvertible>

public extension NSAttributedString {

  /**
   Initialize a `NSAttributedString` with an `NSAttributedStringArrayBuilder`.

   Example:
   ```
   NSMutableAttributedString(separator: "") {
     "If you haven't done so, please "
     "write a review"
       .link("http://google.com")
     "."
   }
   .addDefaultFont(Font.systemFont(ofSize: 12, weight: .regular))
   .addDefaultColor(Color.black(0.8))
   ```

   - Parameters:
     - separator: The separator to join the strings. Default is `""`.
     - builder: The builder block.
   */
  convenience init(separator: NSAttributedStringConvertible = "",
                   @NSAttributedStringArrayBuilder builder: () -> [NSMutableAttributedStringConvertible])
  {
    let array = builder()
    if array.isEmpty {
      self.init(string: "")
    } else if array.count == 1 {
      self.init(attributedString: array[0].asMutableAttributedString())
    } else {
      let rest: NSMutableAttributedString = array[1...]
        .reduce(into: NSMutableAttributedString(string: "")) { partialResult, attributedStringConvertible in
          partialResult.append(separator.asAttributedString())
          partialResult.append(attributedStringConvertible.asMutableAttributedString())
        }
      self.init(attributedString: array[0].asMutableAttributedString() + rest)
    }
  }
}

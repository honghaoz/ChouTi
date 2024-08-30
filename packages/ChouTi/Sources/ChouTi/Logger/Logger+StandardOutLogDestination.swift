//
//  Logger+StandardOutLogDestination.swift
//  ChouTi
//
//  Created by Honghao Zhang on 11/13/21.
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

public extension LogDestination {

  static var standardOut: LogDestination {
    Logger.StandardOutLogDestination().asLogDestination()
  }
}

public extension Logger {

  struct StandardOutLogDestination: LogDestinationType {

    public init() {}

    public func write(_ string: String) {
      Swift.print(string)
    }
  }
}

//  https://github.com/WeTransfer/Diagnostics/blob/master/Sources/Logging/DiagnosticsLogger.swift
//
//  private let inputPipe: Pipe = Pipe()
//  private let outputPipe: Pipe = Pipe()
//
//  public init() {}
//    inputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
//      let data = handle.availableData
//      self?.outputPipe.fileHandleForWriting.write(data)
//    }
//
//    // STDOUT is copied to outputPipe.
//    // With this, you can write to `outputPipe` and it is sent to STDOUT
//    // Can send any data -> outputPipe (STDOUT)
//    //
//    // https://man.cx/dup2
//    dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
//
//    // All STDOUT and STDERR will be sent to inputPipe
//    dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
//    dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
//
//    // the final pipes:
//    // STDOUT & STDERR -> inputPipe -> data -> outputPipe(stdout)
//  }

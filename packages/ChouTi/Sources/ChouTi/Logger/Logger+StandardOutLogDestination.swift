//
//  Logger+StandardOutLogDestination.swift
//
//  Created by Honghao Zhang on 11/13/21.
//  Copyright © 2024 ChouTi. All rights reserved.
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

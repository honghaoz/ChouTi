//
//  ClosureTypes.swift
//
//  Created by Honghao Zhang on 10/18/20.
//  Copyright © 2024 ChouTi. All rights reserved.
//

import Foundation

/// Convenience type aliases for common closure types

public typealias BlockVoid = () -> Void
public typealias BlockThrowsVoid = () throws -> Void
public typealias BlockAsyncVoid = () async -> Void
public typealias BlockAsyncThrowsVoid = () async throws -> Void

/// Prefer `(_ parameter: Bool) -> Void` or `(_ parameter: Bool) throws -> Void` instead of `BlockBool` or `BlockThrowsBool`
/// for better clarity on what the parameter is.

public typealias BlockBool = (Bool) -> Void
public typealias BlockThrowsBool = (Bool) throws -> Void

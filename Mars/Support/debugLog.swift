//
//  debugLog.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

/// Logs the given output to the console when the app is running a debug configuration
///
/// - Parameters:
///   - msg: The message to log to the console
///   - sender: The thing that called this function
///   - function: The function that called this function, the default is #function
///   - line: The line number where this function was called, the default is #line
func debugLog<T>(_ msg: String, from sender: T, function: String = #function, line: Int = #line) {

  guard
    AppEnvironment.current == .debugDevice || AppEnvironment.current == .debugSimulator
    else { return }

  let desc = "\(type(of: sender))"

  print("[\(desc).\(function) \(line)] - \(msg)")
}

//
//  AsyncOperation.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

/// An Operation sub-class with support for asynchronous execution
class AsyncOperation: Operation {

  // MARK: - Properties

  /// Supports the operation state via KVO for OperationQueue
  enum State: String {

    /// The operation is executing
    case executing
    /// The operation has finihsed
    case finished
    /// The operaiton may start executing
    case ready

    fileprivate var keyPath: String { return "is" + rawValue.capitalized }
  }

  /// Holds state of the operation and informs interested key observers of changes
  var state = State.ready {
    willSet {

      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {

      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }
}

extension AsyncOperation {

  // MARK: - Overrides

  override open var isReady: Bool { return super.isReady && state == .ready }
  override open var isExecuting: Bool { return state == .executing }
  override open var isFinished: Bool { return state == .finished }
  override open var isAsynchronous: Bool { return true }

  override open func start() {

    main()
    state = .executing
  }

  override open func cancel() { state = .finished }
}

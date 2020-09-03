//
//  PersistentContainer.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import CoreData

class PersistentContainer: NSPersistentContainer {

  enum Model {

    case Mars

    var name: String { return String(describing: self).capitalized }
  }

  private static var `default`: PersistentContainer = {

    let container = PersistentContainer(name: Model.Mars.name)

    container.loadPersistentStores(completionHandler: { (_, _error) in

      guard let error = _error else { return }

      debugLog(error.localizedDescription, from: self)
    })

    return container
  }()

  /// The main view context for reading from the model
  static var viewContext: NSManagedObjectContext {

    let context = PersistentContainer.default.viewContext
    context.automaticallyMergesChangesFromParent = true

    return context
  }

  /// Creates a new background context from the persistent container
  static func newBackgroundContext() -> NSManagedObjectContext {

    let context = `default`.newBackgroundContext()
    context.automaticallyMergesChangesFromParent = true

    return context
  }
}

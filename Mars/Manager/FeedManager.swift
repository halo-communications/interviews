//
//  FeedManager.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation
import CoreData

protocol FeedManagerDelegate: class {

  func feed(status: String)
}

class FeedManager {

  // MARK: - Properties

  static let current = FeedManager()
  private lazy var session = URLSession(configuration: .default)
  private lazy var queue: OperationQueue = {

    let q = OperationQueue()
    q.qualityOfService = .userInitiated

    return q
  }()
  private var isFeedBeingUpdated = false
  private enum Rover: String { case curiosity, opportunity, spirit }
  weak var delegate: FeedManagerDelegate?

  // MARK: - Private

  private func process(serialized dto: Data) {

    let context = PersistentContainer.newBackgroundContext()

      context.perform {

        do {

          FeedPhoto.make(context: context, dto: try JSONDecoder().decode(DTOPhotos.self, from: dto))
          try context.save()

        } catch { debugLog(error.localizedDescription, from: self) }
      }
  }

  private func getPhotoData(rover: Rover, sol: Int16) {

    let task: NetworkTask
    let handler = NetworkTask.Handler()
    handler.completionBlock = { [weak self] in
      DispatchQueue.main.async {

        switch handler.result {

        case .success(let data): self?.process(serialized: data)
        case .failure(let error): debugLog(error.localizedDescription, from: self)
        }

        self?.isFeedBeingUpdated = false
        self?.delegate?.feed(status: "Feed updated (sol \(sol))")
      }
    }

    switch rover {

    case .curiosity: task = NetworkTask(session: session, endpoint: .photosCuriosity(sol))
    case .opportunity: task = NetworkTask(session: session, endpoint: .photosOpportunity(sol))
    case .spirit: task = NetworkTask(session: session, endpoint:  .photosSpirit(sol))
    }

    handler.addDependency(task)
    queue.addOperations([task, handler], waitUntilFinished: false)
  }

  private func doFeedItemsExist() -> Bool {

    let context = PersistentContainer.newBackgroundContext()
    var exists = false

    context.performAndWait {

      let request: NSFetchRequest<FeedPhoto> = FeedPhoto.fetchRequest()
      request.resultType = .countResultType

      do { exists = try context.count(for: request) > 0 ? true : false }
      catch { debugLog(error.localizedDescription, from: self) }
    }

    return exists
  }

  // MARK: - Internal

  func makeMoreFeedItems() {

    guard isFeedBeingUpdated == false else { return }
    isFeedBeingUpdated = true

    delegate?.feed(status: "Updating feed")

    // Get the earliest sol for each rover that has not yet been fetched and load that day's
    // photo data as feed items

    [Rover.curiosity, Rover.opportunity, Rover.spirit].forEach {

      let rover = $0
      let request: NSFetchRequest<PhotoMeta> = PhotoMeta.fetchRequest()
      request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
        NSPredicate(
          format: "%K LIKE [c] %@",
          #keyPath(PhotoMeta.rover),
          rover.rawValue),
        NSPredicate(format: "%K = NO", #keyPath(PhotoMeta.fetchedPhotosData))])
      request.sortDescriptors = [NSSortDescriptor(key: #keyPath(PhotoMeta.sol), ascending: true)]
      request.fetchLimit = 1
      let context = PersistentContainer.newBackgroundContext()

      do {

        let meta = try context.fetch(request)
        guard let solMeta = meta.first else { return }

        getPhotoData(rover: rover, sol: solMeta.sol)

      } catch { debugLog(error.localizedDescription, from: self) }
    }
  }

  // MARK: - Lifecycle

  private init() {

    PhotoMetaCoordinator.current.start { [weak self] in
      DispatchQueue.main.async {

        guard self?.doFeedItemsExist() == false else { return }

        self?.makeMoreFeedItems()
      }
    }
  }
}

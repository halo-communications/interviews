//
//  PhotoMetaCoordinator.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation
import CoreData

protocol PhotoMetaCoordinatorDelegate: class {

  func coordinator(status: String)
}

class PhotoMetaCoordinator {

  // MARK: - Properties

  static let current = PhotoMetaCoordinator()
  private lazy var session = URLSession(configuration: .default)
  private lazy var queue: OperationQueue = {

    let q = OperationQueue()
    q.qualityOfService = .userInitiated

    return q
  }()
  private enum UserDefaultKey: String {

    case didFetchPhotoMeta
  }
  private var didFetchPhotoMetadata: Bool {

    get { return UserDefaults.standard.bool(forKey: UserDefaultKey.didFetchPhotoMeta.rawValue) }
    set { UserDefaults.standard.set(newValue, forKey: UserDefaultKey.didFetchPhotoMeta.rawValue) }
  }
  private class SaveMetadata: Operation {

    private lazy var providers: [NetworkTaskProvider] = self.dependencies
      .compactMap { return $0 as? NetworkTaskProvider }

    private func make(dto: Data) throws -> DTOManifest {

      return try JSONDecoder().decode(DTOManifest.self, from: dto)
    }

    private func process(serialized dto: Data) {

      let context = PersistentContainer.newBackgroundContext()
      context.performAndWait {

        do {

          PhotoMeta.make(context: context, dto: try make(dto: dto))
          try context.save()

        } catch { debugLog(error.localizedDescription, from: self) }
      }
    }

    override func main() {

      providers.forEach {

        switch $0.result {

        case .success(let data): process(serialized: data)
        case .failure(let error): debugLog(error.localizedDescription, from: self)
        }
      }
    }
  }
  weak var delegate: PhotoMetaCoordinatorDelegate?

  // MARK: - Private

  private func makeGetRoverManifestsOperations(dependant op: Operation) -> [Operation] {

    return [
      Platform.Endpoint.manifestCuriosity,
      Platform.Endpoint.manifestOpportunity,
      Platform.Endpoint.manifestSpirit].map {

        let task = NetworkTask(session: session, endpoint: $0)

        op.addDependency(task)
        return task
    }
  }

  private func fetchMetadataIfNeeded(completion: @escaping () -> Void) {

    guard didFetchPhotoMetadata == false else {

      completion()
      return
    }

    let save = SaveMetadata()
    let ops: [Operation] = makeGetRoverManifestsOperations(dependant: save) + [save]
    save.completionBlock = { [weak self] in

      self?.didFetchPhotoMetadata = true

      completion()
      self?.delegate?.coordinator(status: "Finished loading mission manifest")
    }

    delegate?.coordinator(status: "Loading mission manifest...")
    queue.addOperations(ops, waitUntilFinished: false)
  }

  // MARK: - Lifecycle

  private init() { }

  // MARK: Internal

  /// Will fetch Mar's rover mission manifests that will be used to create PhotoMeta instances for each applicable sol
  /// - Parameter completion: An async handler that will execute immediately if metadata has already been fetched or after
  /// metadata has been fetched.
  func start(completion: @escaping () -> Void) { fetchMetadataIfNeeded(completion: completion) }
}

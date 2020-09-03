//
//  NetworkTask.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

enum NetworkError: Error {

  case fileError (Error)
  case missingData, missingTaskURL, missingURL
  case networkDependencyNotFound, notStarted
  case taskError (Error)

  var localizedDescription: String {

    switch self {

    case .fileError: return "Error moving temporary file"
    case .missingData: return "The task's data is nil"
    case .missingTaskURL: return "Missing task url from endpoint"
    case .missingURL: return "Missing local url"
    case .networkDependencyNotFound: return "Dependent operation not found"
    case .notStarted: return "Operation not started"
    case .taskError: return "Underlying task error"
    }
  }
}

protocol NetworkTaskProvider {

  var result: Result<Data, NetworkError> { get }
}

class NetworkTask: AsyncOperation, NetworkTaskProvider {

  // MARK: - Properties

  class Handler: Operation, NetworkTaskProvider {

    lazy var result = (dependencies
      .filter { $0 is NetworkTaskProvider }
      .first as? NetworkTaskProvider)?.result ?? .failure(.networkDependencyNotFound)
  }

  typealias Error = NetworkError
  private let session: URLSession
  private let endpoint: Platform.Endpoint
  var result: Result<Data, Error>

  // MARK: - Lifecycle

  init(session: URLSession, endpoint: Platform.Endpoint) {

    self.session = session
    self.endpoint = endpoint
    self.result = .failure(.notStarted)
    super.init()
  }

  // MARK: - Overrides

  override func main() {

    guard var url = endpoint.url else {

      result = .failure(.missingURL)
      state = .finished
      return
    }

    Platform.addAuthorizationParameter(url: &url)

    session.dataTask(with: url) { [weak self] (unsafeData, _, unsafeError) in

      defer { self?.state = .finished  }

      guard let data = unsafeData else {

        if let error = unsafeError { self?.result = .failure(.taskError(error)) }
        else { self?.result = .failure(.missingData) }
        return
      }

      self?.result = .success(data)
    }.resume()
  }
}

protocol NetworkDownloadTaskProvider {

  var result: Result<(remoteURL: URL, localURL: URL), NetworkError> { get }
}

class NetworkDownloadTask: AsyncOperation, NetworkDownloadTaskProvider {

  // MARK: - Properties

  class Handler: Operation, NetworkDownloadTaskProvider {

    lazy var result = (dependencies
      .filter { $0 is NetworkDownloadTaskProvider }
      .first as? NetworkDownloadTaskProvider)?.result ?? .failure(.networkDependencyNotFound)
  }

  private let session: URLSession
  private let url: URL
  typealias Error = NetworkError
  var result: Result<(remoteURL: URL, localURL: URL), NetworkError>

  // MARK: - Private

  private func move(temporaryURL: URL) throws -> URL {

    let to = FileManager.default.urls(
      for: .cachesDirectory,
      in: .userDomainMask)[0].appendingPathComponent(temporaryURL.lastPathComponent)

    try FileManager.default.moveItem(at: temporaryURL,to: to)
    return to
  }

  // MARK: - Lifecycle

  init(session: URLSession, url: URL) {

    self.session = session
    self.url = url
    self.result = .failure(.notStarted)
    super.init()
  }

  // MARK: - Overrides

  override func main() {

    session.downloadTask(with: url) { [weak self] (unsafeURL, _, unsafeError) in

      guard let `self` = self else { return }

      defer { self.state = .finished }

      guard let tempURL = unsafeURL else {

        if let error = unsafeError { self.result = .failure(.taskError(error)) }
        else { self.result = .failure(.missingTaskURL) }
        return
      }

      do {

        let localURL = try self.move(temporaryURL: tempURL)
        self.result = .success((remoteURL: self.url, localURL: localURL))

      } catch {

        self.result = .failure(.fileError(error))
      }
    }.resume()
  }
}

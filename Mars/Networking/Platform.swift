//
//  Platform.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

struct Platform {

  // MARK: - Properties

  private static let apiKey = "CWkINYoDgXFE5RHArKXC3wWKvR3Uev936arKXHth"
  private static let host = "https://api.nasa.gov"
  private static let manifestCuriosityPath =  "/mars-photos/api/v1/manifests/curiosity"
  private static let manifestOpportunityPath = "/mars-photos/api/v1/manifests/opportunity"
  private static let manifestSpiritPath = "/mars-photos/api/v1/manifests/spirit"
  private static let photosCuriosityPath = "/mars-photos/api/v1/rovers/curiosity/photos"
  private static let photosOpportuinityPath = "/mars-photos/api/v1/rovers/opportunity/photos"
  private static let photosSpiritPath = "/mars-photos/api/v1/rovers/spirit/photos"
  private static let parameterSol = "sol"
  private static let parameterAPIKey = "api_key"

  enum Endpoint {

    // the associated value for photo endpoints indicates the sol to be used as a parameter

    case manifestCuriosity, manifestOpportunity, manifestSpirit
    case photosCuriosity (Int16)
    case photosOpportunity (Int16)
    case photosSpirit (Int16)

    private func update(url: inout URL, queryItem: URLQueryItem) {

      guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
      var items = components.queryItems ?? []

      items.append(queryItem)

      components.queryItems = items
      guard let _url = components.url else { return }
      url = _url
    }

    var url: URL? {

      typealias P = Platform
      let base = URL(string: P.host)

      switch self {

      case .manifestCuriosity: return base?.appendingPathComponent(P.manifestCuriosityPath)
      case .manifestOpportunity: return base?.appendingPathComponent(P.manifestOpportunityPath)
      case .manifestSpirit: return base?.appendingPathComponent(P.manifestSpiritPath)
      case .photosCuriosity(let sol):

        guard var url = base?.appendingPathComponent(P.photosCuriosityPath) else { return nil }

        update(url: &url, queryItem: URLQueryItem(name: P.parameterSol, value: "\(sol)"))
        return url

      case .photosOpportunity(let sol):

        guard var url = base?.appendingPathComponent(P.photosOpportuinityPath) else { return nil }

        update(url: &url, queryItem: URLQueryItem(name: P.parameterSol, value: "\(sol)"))
        return url

      case .photosSpirit(let sol):

        guard var url = base?.appendingPathComponent(P.photosSpiritPath) else { return nil }

        update(url: &url, queryItem: URLQueryItem(name: P.parameterSol, value: "\(sol)"))
        return url
      }
    }
  }

  // MARK: - Internal

  static func addAuthorizationParameter(url: inout URL) {

    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
    var queryItems = components.queryItems ?? []

    queryItems.append(URLQueryItem(name: Platform.parameterAPIKey, value: Platform.apiKey))

    components.queryItems = queryItems

    guard let _url = components.url else { return }
    url = _url
  }
}

//
//  FeedPhoto+CoreDataClass.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//
//

import Foundation
import CoreData

@objc(FeedPhoto)
public class FeedPhoto: NSManagedObject { }

extension FeedPhoto {

  private static let formatter: DateFormatter = {

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    return formatter
  }()

  private static func updateURLSchemeIfNeeded(url: inout URL) {

    guard url.scheme != "https" else { return }
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {

      debugLog("could not make url components", from: self)
      return
    }

    components.scheme = "https"

    guard let _url = components.url else {

      debugLog("could not make updated url", from: self)
      return
    }

    url = _url
  }

  static func make(context: NSManagedObjectContext, dto: DTOPhotos) {

    dto.photos.forEach {

      guard let date = formatter.date(from: $0.earth_date) else {

        debugLog("could not make date, dto: \($0)", from: self)
        return
      }

      guard var url = URL(string: $0.img_src) else {

        debugLog("could not make remote image url", from: self)
        return
      }

      updateURLSchemeIfNeeded(url: &url)

      let feedItem = FeedPhoto(context: context)
      feedItem.date = date
      feedItem.nasaIdentifier = Int32($0.id)
      feedItem.remoteImageURL = url
      feedItem.rover = $0.rover.name
      feedItem.sol = Int16($0.sol)
    }
  }
}

//
//  FeedPhoto+CoreDataProperties.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedPhoto {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedPhoto> {
    return NSFetchRequest<FeedPhoto>(entityName: "FeedPhoto")
  }

  @NSManaged public var rover: String
  @NSManaged public var date: Date
  @NSManaged public var remoteImageURL: URL
  @NSManaged public var sol: Int16
  @NSManaged public var nasaIdentifier: Int32
}

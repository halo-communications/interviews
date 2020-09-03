//
//  PhotoMeta+CoreDataProperties.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//
//

import Foundation
import CoreData


extension PhotoMeta {

  @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoMeta> {
    return NSFetchRequest<PhotoMeta>(entityName: "PhotoMeta")
  }

  @NSManaged public var rover: String
  @NSManaged public var sol: Int16
  @NSManaged public var fetchedPhotosData: Bool
}

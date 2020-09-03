//
//  PhotoMeta+CoreDataClass.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//
//

import Foundation
import CoreData

@objc(PhotoMeta)
public class PhotoMeta: NSManagedObject { }

extension PhotoMeta {

  static func make(context: NSManagedObjectContext, dto: DTOManifest) {

    let rover = dto.photo_manifest.name

    dto.photo_manifest.photos.forEach {

      let meta = PhotoMeta(context: context)
      meta.rover = rover
      meta.sol = Int16($0.sol)
    }
  }
}

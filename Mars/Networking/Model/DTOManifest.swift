//
//  DTOManifest.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

struct DTOManifest: Codable {

  struct Photo: Codable {

    let sol: Int
  }

  struct Manifest: Codable {

    let name: String
    let max_sol: Int
    let photos: [Photo]
  }

  let photo_manifest: Manifest
}

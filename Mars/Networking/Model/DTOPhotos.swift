//
//  DTOPhotos.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

struct DTOPhotos: Codable {

  struct Rover: Codable {

    let name: String
  }

  struct Photo: Codable {

    let earth_date: String
    let id: Int
    let img_src: String
    let sol: Int
    let rover: Rover
  }

  let photos: [Photo]
}

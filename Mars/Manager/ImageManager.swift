//
//  ImageManager.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import UIKit

protocol ImageManagerDelegate: class {

  func manager(status: String)
}

class ImageManager {

  // MARK: - Properties

  static let current = ImageManager()
  weak var delegate: ImageManagerDelegate?

  // MARK: - Lifecycle

  private init() { }

  // MARK: - Internal

  func image(at url: URL, completion: @escaping (_ imageURL: URL) -> Void) {

  }
}

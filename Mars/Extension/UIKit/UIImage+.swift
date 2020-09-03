//
//  UIImage+.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {

  private static func makeImageSourceOptions(imageView: UIImageView) -> CFDictionary {

    let size = imageView.bounds.size

    return [
        kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
    ] as CFDictionary
  }

  static func load(at url: URL, for imageView: UIImageView) -> UIImage? {

    let options = makeImageSourceOptions(imageView: imageView)

    guard
      let source = CGImageSourceCreateWithURL(url as NSURL, nil),
      let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options)
      else { return nil }

    return UIImage(cgImage: image)
  }
}

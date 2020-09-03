//
//  CACornerMask+.swift
//  Mars
//
//  Created by Fred Faust on 1/13/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import QuartzCore

extension CACornerMask {

  static let all: CACornerMask = [
    .layerMaxXMaxYCorner,
    .layerMaxXMinYCorner,
    .layerMinXMaxYCorner,
    .layerMinXMinYCorner]
}

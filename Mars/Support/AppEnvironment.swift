//
//  AppEnvironment.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import Foundation

enum AppEnvironment {

  case debugSimulator, debugDevice, production, testflight, unknown

  static var current: AppEnvironment {

    #if targetEnvironment(simulator)

    return .debugSimulator
    #endif

    #if DEBUG

    return .debugDevice
    #endif

    guard let path = Bundle.main.appStoreReceiptURL?.path else { return .unknown }

    if path.contains("sandboxReceipt") { return .testflight }

    return .production
  }
}

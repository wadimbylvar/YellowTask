//
//  NSError+Extensions.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import Foundation

private let ParkSuiteErrorDomain = "ParkSuiteErrorDomain"
private let InternalErrorCode = -1

extension NSError {
  convenience init(description: String) {
    self.init(domain: ParkSuiteErrorDomain, code: InternalErrorCode, userInfo: [NSLocalizedDescriptionKey: description])
  }
}

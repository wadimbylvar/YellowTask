//
//  Localizable.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/26/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import Foundation

public func LS(_ string: String, comment: String = "") -> String {
  return NSLocalizedString(string, comment: comment)
}

protocol Localizable {
  var localized: String { get }
}

extension String: Localizable {
  var localized: String {
    return LS(self)
  }
}

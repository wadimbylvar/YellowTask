//
//  XIBLocalizable.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/26/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit

protocol XIBLocalizable {
  var xibLocKey: String? { get set }
}

extension UILabel: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      text = key?.localized
    }
  }
}

extension UIButton: XIBLocalizable {
  @IBInspectable var xibLocKey: String? {
    get { return nil }
    set(key) {
      setTitle(key?.localized, for: .normal)
    }
  }
}

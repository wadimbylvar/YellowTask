//
//  Array+Extensions.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/25/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

extension Array {
  subscript (safe index: Int) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

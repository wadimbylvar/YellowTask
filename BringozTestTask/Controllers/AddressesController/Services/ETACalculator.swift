//
//  ETACalculator.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import Foundation

enum DistanceType {
  case aerial
}

protocol ETACalculator {
  // `speed` is measured in m/sec
  func timeInterval(from: Address,
                    to: Address,
                    with speed: Double,
                    distanceType: DistanceType) -> TimeInterval
}

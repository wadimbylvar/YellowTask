//
//  CoreLocationDistanceResolver.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import CoreLocation

class CoreLocationDistanceResolver: DistanceResolver {
  func timeInterval(from: Address,
                    to: Address,
                    with speed: Double,
                    distanceType: DistanceType) -> TimeInterval {
    let distance = self.distance(from: from.clLocation, to: to.clLocation, distanceType: distanceType)
    return distance / speed
  }
  
  private func distance(from: CLLocation, to: CLLocation, distanceType: DistanceType) -> CLLocationDistance {
    switch distanceType {
    case .aerial:
      return to.distance(from: from)
    }
  }
}

fileprivate extension Address {
  var clLocation: CLLocation {
    return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
  }
}

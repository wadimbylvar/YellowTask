//
//  Address.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import CoreLocation
import RxSwift

protocol PresentableAddress {
  var name: String { get }
  func address() -> Observable<Address>
}

protocol Address {
  var name: String { get }
  var coordinate: CLLocationCoordinate2D { get }
}

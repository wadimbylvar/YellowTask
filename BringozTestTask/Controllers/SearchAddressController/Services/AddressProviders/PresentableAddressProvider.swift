//
//  PresentableAddressProvider.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import RxSwift

protocol PresentableAddress {
  var name: String { get }
  func address() -> Observable<Address>
}

protocol PresentableAddressProvider {
  func presentableAddresses(for name: String) -> Observable<[PresentableAddress]>
}

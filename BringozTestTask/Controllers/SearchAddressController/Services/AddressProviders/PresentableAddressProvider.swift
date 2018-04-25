//
//  PresentableAddressProvider.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import RxSwift

protocol PresentableAddressProvider {
  func presentableAddresses(for name: String) -> Observable<[PresentableAddress]>
}

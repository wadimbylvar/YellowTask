//
//  AddressWithETA.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import Foundation

class AddressWithETA {
  let address: Address
  var eta: Date
  
  var binder: AddressWithETABinder!
  
  init(address: Address, eta: Date) {
    self.address = address
    self.eta = eta
    binder = BaseAddressWithETABinder(owner: self)
  }
}

//
//  BaseAddressWithETABinder.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/25/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

typealias AddressBindingRule = (AddressWithETA, AddressWithETA) -> Bool

protocol AddressWithETABinder {
  func bind(_ item: AddressWithETA, rule: AddressBindingRule?)
  func unbind()
  
  func isBinded() -> Bool
  func isBinded(to: AddressWithETA) -> Bool
}

class BaseAddressWithETABinder: AddressWithETABinder {
  
  private weak var owner: AddressWithETA?
  private weak var bindedItem: AddressWithETA?
  private var rule: AddressBindingRule?
  
  init(owner: AddressWithETA) {
    self.owner = owner
  }
  
  func bind(_ item: AddressWithETA, rule: AddressBindingRule?) {
    bindedItem = item
    self.rule = rule
  }
  
  func unbind() {
    bindedItem = nil
    rule = nil
  }
  
  func isBinded() -> Bool {
    return bindedItem != nil
  }
  
  func isBinded(to item: AddressWithETA) -> Bool {
    guard let owner = owner, let bindedItem = bindedItem else {
      return false
    }
    
    guard let rule = rule else {
      return bindedItem === item
    }
    
    return rule(owner, bindedItem)
  }
}

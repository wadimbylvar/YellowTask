//
//  ViewControllersFactory.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/26/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit

enum AppViewControllers {
  case addresses
  case searchAddress
}

class ViewControllersFactory {
  
  static let shared: ViewControllersFactory = ViewControllersFactory()
  
  func rootViewController() -> UIViewController {
    let vc = viewController(for: .addresses)
    return UINavigationController(rootViewController: vc)
  }
  
  func viewController(for key: AppViewControllers) -> UIViewController {
    switch key {
    case .addresses:
      return addressesViewController()
    case .searchAddress:
      return searchAddressViewController()
    }
  }
  
  private func addressesViewController() -> UIViewController {
    let vc = AddressesViewController()
    vc.etaCalculator = CoreLocationETACalculator()
    return vc
  }
  
  private func searchAddressViewController() -> UIViewController {
    let vc = SearchAddressViewController()
    vc.addressProvider = GoogleAddressProvider()
    return vc
  }
}

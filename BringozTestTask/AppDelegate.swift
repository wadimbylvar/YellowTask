//
//  AppDelegate.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    setupAppearance()
    setupSDKs()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = ViewControllersFactory.shared.rootViewController()
    window?.makeKeyAndVisible()
    
    return true
  }
}

fileprivate extension AppDelegate {
  func setupAppearance() {
    UINavigationBar.appearance().isTranslucent = false
    UINavigationBar.appearance().tintColor = .white
    UINavigationBar.appearance().barTintColor = .bringozOrange
    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    
    UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
  }
  
  func setupSDKs() {
    setupGoogleSDKs()
  }
  
  private func setupGoogleSDKs() {
    GMSPlacesClient.provideAPIKey("AIzaSyD_ulMZsmR3mQ5IhwNf1rGqfNjenSiSi4w")
  }
}

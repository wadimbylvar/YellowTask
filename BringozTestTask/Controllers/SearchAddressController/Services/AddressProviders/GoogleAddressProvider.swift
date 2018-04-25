//
//  GoogleAddressProvider.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import Foundation
import RxSwift
import GooglePlaces

class GoogleAddressProvider: PresentableAddressProvider {
  
  func address(forGooglePresentableAddressId id: String) -> Observable<Address> {
    return Observable<Address>.create { (observer) -> Disposable in
      GMSPlacesClient.shared().lookUpPlaceID(id) { (place, error) -> Void in
        if let error = error {
          observer.onError(error)
        } else if let place = place {
          observer.onNext(place)
          observer.onCompleted()
        }
      }
      return Disposables.create()
    }
    .subscribeOn(MainScheduler.instance)
    .observeOn(CurrentThreadScheduler.instance)
  }
  
  func presentableAddresses(for name: String) -> Observable<[PresentableAddress]> {
    return Observable<[PresentableAddress]>.create { (observer) -> Disposable in
      GMSPlacesClient.shared().autocompleteQuery(name, bounds: nil, filter: nil, callback: { (predictions, error) in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onNext(predictions ?? [])
          observer.onCompleted()
        }
      })
      return Disposables.create()
    }
    .subscribeOn(MainScheduler.instance)
    .observeOn(CurrentThreadScheduler.instance)
  }
}

extension GMSPlace: Address { }

extension GMSAutocompletePrediction: PresentableAddress {
  var name: String {
    return attributedFullText.string
  }
  
  func address() -> Observable<Address> {
    guard let placeId = placeID else {
      let description = "\(name) has no place ID."
      return .error(NSError(description: description))
    }
    return GoogleAddressProvider().address(forGooglePresentableAddressId: placeId)
  }
}

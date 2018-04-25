//
//  UIKit+DisposeBag.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift

private var kDisposeBagAssociatedKey: UInt8 = 0
private func defaultDisposeBagForObject(_ object: AnyObject) -> DisposeBag {
  if let disposeBag = objc_getAssociatedObject(object, &kDisposeBagAssociatedKey) as? DisposeBag {
    return disposeBag
  } else {
    let disposeBag = DisposeBag()
    objc_setAssociatedObject(object, &kDisposeBagAssociatedKey, disposeBag, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    return disposeBag
  }
}

extension UIView {
  public var disposeBag: DisposeBag {
    return defaultDisposeBagForObject(self)
  }
}

extension UIViewController {
  public var disposeBag: DisposeBag {
    return defaultDisposeBagForObject(self)
  }
}

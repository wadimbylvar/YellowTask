//
//  View.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/26/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift

open class View: UIView {
  
  open func customInit() {
    translatesAutoresizingMaskIntoConstraints = false
  }
  
  required override public init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    customInit()
  }
  
  open override func updateConstraints() {
    setupViewConstraints()
    super.updateConstraints()
  }
  
  open func setupViewConstraints() {}
}

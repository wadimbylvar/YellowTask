//
//  TableViewCell.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift

class TableViewCell: UITableViewCell {
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    updateSelected(selected, animated: animated)
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    customInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    customInit()
  }
  
  func customInit() {
    backgroundColor = UIColor.clear
    setNeedsUpdateConstraints()
  }
  
  override func updateConstraints() {
    setupViewConstraints()
    super.updateConstraints()
  }
  
  func updateSelected(_ selected: Bool, animated: Bool) { }
  func setupViewConstraints() { }
}

extension Reactive where Base: UITableViewCell {
  var reuse: Observable<[Any]> {
    return sentMessage(#selector(base.prepareForReuse))
  }
}

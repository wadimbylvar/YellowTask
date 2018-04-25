//
//  AddressETATableViewCell.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import DTModelStorage
import RxSwift
import RxCocoa

struct AddressETATableViewCellModel {
  let title: String
  let etaBehaviorRelay: BehaviorRelay<String?>
  
  init(title: String, eta: String?) {
    self.title = title
    etaBehaviorRelay = BehaviorRelay(value: eta)
  }
}

// MARK: -
class AddressETATableViewCell: TableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var etaLabel: UILabel!
}

extension AddressETATableViewCell: ModelTransfer {
  func update(with model: AddressETATableViewCellModel) {
    titleLabel.text = model.title
    model.etaBehaviorRelay
      .takeUntil(rx.reuse)
      .subscribe(onNext: { [weak self] (eta) in
        self?.etaLabel.text = eta
      }).disposed(by: disposeBag)
  }
}

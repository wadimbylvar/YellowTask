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
  
  let topBridgeViewHidden = BehaviorRelay<Bool>(value: true)
  let bottomBridgeViewHidden = BehaviorRelay<Bool>(value: true)
  
  init(title: String, eta: String?) {
    self.title = title
    etaBehaviorRelay = BehaviorRelay(value: eta)
  }
}

// MARK: -
class AddressETATableViewCell: UITableViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var etaLabel: UILabel!
  @IBOutlet weak var radioButton: RadioButton!
  @IBOutlet weak var topBridgeView: UIView!
  @IBOutlet weak var bottomBridgeView: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    topBridgeView.backgroundColor = .bringozOrange
    bottomBridgeView.backgroundColor = .bringozOrange
  }
}

extension AddressETATableViewCell: ModelTransfer {
  func update(with model: AddressETATableViewCellModel) {
    titleLabel.text = model.title
    
    model.etaBehaviorRelay
      .takeUntil(rx.reuse)
      .subscribe(onNext: { [weak self] (eta) in
        self?.etaLabel.text = eta
      }).disposed(by: disposeBag)
    
    Observable.combineLatest([model.topBridgeViewHidden, model.bottomBridgeViewHidden])
      .takeUntil(rx.reuse)
      .subscribe(onNext: { [weak self] (bridgeViewsHiddenStates) in
        if bridgeViewsHiddenStates.contains(false) {
          self?.radioButton.select(animated: true)
        } else {
          self?.radioButton.deselect(animated: true)
        }
      }).disposed(by: disposeBag)
    
    model.topBridgeViewHidden
      .takeUntil(rx.reuse)
      .subscribe(onNext: { [weak self] (hidden) in
        self?.topBridgeView.isHidden = hidden
      }).disposed(by: disposeBag)
    
    model.bottomBridgeViewHidden
      .takeUntil(rx.reuse)
      .subscribe(onNext: { [weak self] (hidden) in
        self?.bottomBridgeView.isHidden = hidden
      }).disposed(by: disposeBag)
  }
}

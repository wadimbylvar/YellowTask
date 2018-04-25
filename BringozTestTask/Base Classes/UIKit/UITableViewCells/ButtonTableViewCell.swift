//
//  ButtonTableViewCell.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import DTModelStorage

struct ButtonTableViewCellModel {
  let title: String
  let buttonPublishSubject = PublishSubject<Void>()
  
  init(title: String) {
    self.title = title
  }
}

// MARK: -
class ButtonTableViewCell: TableViewCell {
  
  let button: UIButton = {
    let button = UIButton()
    return button
  }()
  
  var buttonInsets: UIEdgeInsets = .zero {
    didSet {
      if buttonInsets != oldValue {
        setNeedsUpdateConstraints()
      }
    }
  }
  
  override func customInit() {
    contentView.addSubview(button)
    super.customInit()
  }
  
  override func setupViewConstraints() {
    button.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview().inset(buttonInsets)
    }
  }
}

extension ButtonTableViewCell: ModelTransfer {
  func update(with model: ButtonTableViewCellModel) {
    button.setTitle(model.title, for: .normal)
    button.rx.tap
      .takeUntil(rx.reuse)
      .subscribe(onNext: { () in
        model.buttonPublishSubject.onNext(())
      }).disposed(by: disposeBag)
  }
}

//
//  LabelTableViewCell.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import DTModelStorage

struct LabelTableViewCellModel {
  let text: String
}

class LabelTableViewCell: TableViewCell {
  
  let label: UILabel = {
    let label = UILabel()
    return label
  }()
  
  var labelInsets: UIEdgeInsets = .zero {
    didSet {
      if labelInsets != oldValue {
        setNeedsUpdateConstraints()
      }
    }
  }
  
  override func customInit() {
    contentView.addSubview(label)
    super.customInit()
  }
  
  override func setupViewConstraints() {
    label.snp.remakeConstraints { (make) in
      make.edges.equalToSuperview().inset(labelInsets)
    }
  }
  
}

extension LabelTableViewCell: ModelTransfer {
  func update(with model: LabelTableViewCellModel) {
    label.text = model.text
  }
}

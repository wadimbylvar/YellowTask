//
//  AddressesViewController.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DTTableViewManager

fileprivate enum AddAddressButtonConfiguration {
  static var height: CGFloat {
    return 60
  }
  static var font: UIFont {
    return UIFont.systemFont(ofSize: 22, weight: .semibold)
  }
  static var cornerRadius: CGFloat {
    return height / 2
  }
  static var cellHeight: CGFloat {
    return cellButtonInsets.top + cellButtonInsets.bottom + height
  }
  static var cellButtonInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30)
  }
}

// MARK: -
class AddressesViewController: TableViewController {
  
  // MARK: Properties
  var addresses: [AddressWithETA] = []
  var addressesCellModels: [AddressETATableViewCellModel] = []
  
  var speed = 10.0 // measured in m/sec
  
  let removeButton = UIBarButtonItem(title: "Reset", style: .plain, target: nil, action: nil)
  let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
  
  lazy var distanceResolver: ETACalculator = CoreLocationETACalculator()
  
  lazy var etaDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = DateFormats.addressETA
    dateFormatter.locale = Locale.autoupdatingCurrent
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    return dateFormatter
  }()
  
  // MARK: - Life
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    recalculateETA()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tableView.isEditing = false
  }
  
  override func setupForm() {
    super.setupForm()
    
    title = "Addresses"
    
    removeButton.rx.tap.subscribe(onNext: { [weak self] () in
      self?.resetData()
    }).disposed(by: disposeBag)
    navigationItem.leftBarButtonItem = removeButton
    
    editButton.rx.tap.subscribe(onNext: { [weak self] () in
      self?.editButtonTapped()
    }).disposed(by: disposeBag)
    navigationItem.rightBarButtonItem = editButton
  }
  
  override func setupTable() {
    super.setupTable()
    
    tableView.allowsSelectionDuringEditing = false
    
    manager.register(AddressETATableViewCell.self)
    manager.register(ButtonTableViewCell.self)
    
    manager.configure(AddressETATableViewCell.self) { (cell, model, indexPath) in
      cell.selectionStyle = .none
    }
    manager.configure(ButtonTableViewCell.self) { [weak self] (cell, model, indexPath) in
      cell.selectionStyle = .none
      cell.buttonInsets = AddAddressButtonConfiguration.cellButtonInsets
      self?.setupAddAddressButton(cell.button)
    }
    
    manager.heightForCell(withItem: ButtonTableViewCellModel.self) { (model, indexPath) -> CGFloat in
      return AddAddressButtonConfiguration.height
    }
    
    manager.didSelect(AddressETATableViewCell.self) { [weak self] (cell, model, indexPath) in
      guard let wself = self else { return }
      
      let address = wself.addresses[indexPath.row]
      guard let previousAddress = wself.addresses[safe: indexPath.row - 1] else {
        return
      }
      
      if address.binder.isBinded() {
        wself.unbindModel(at: indexPath.row)
      } else {
        wself.bindModel(at: indexPath.row, to: previousAddress)
      }
    }
    
    manager.canMove(AddressETATableViewCell.self) { (cell, model, indexPath) -> Bool in true }
    manager.canMove(ButtonTableViewCell.self) { (cell, model, indexPath) -> Bool in false }
    
    manager.targetIndexPathForMove(AddressETATableViewCell.self) { [unowned self] (to, cell, model, from) -> IndexPath in
      if from.section != to.section {
        return from
      }
      
      if to.row == 0 || to.row == self.addresses.count - 1 {
        return to
      }
      
      if from.row > to.row {
        if let previousAddress = self.addresses[safe: to.row - 1],
           let targetAddress = self.addresses[safe: to.row],
           targetAddress.binder.isBinded(to: previousAddress) { return from }
      } else {
        if let previousAddress = self.addresses[safe: to.row],
           let targetAddress = self.addresses[safe: to.row + 1],
           targetAddress.binder.isBinded(to: previousAddress) { return from }
      }
      
      return to
    }
    
    manager.move(AddressETATableViewCell.self) { [weak self] (destinationIndexPath, cell, model, sourceIndexPath) in
      guard let wself = self else { return }
      wself.manager.memoryStorage.moveItemWithoutAnimation(from: sourceIndexPath, to: destinationIndexPath)
      
      wself.unbindModel(at: sourceIndexPath.row)
      
      let nextItemIndex = sourceIndexPath.row + 1
      if nextItemIndex < wself.addresses.count {
        wself.unbindModel(at: nextItemIndex)
      }
      
      wself.moveModel(from: sourceIndexPath.row, to: destinationIndexPath.row)
      wself.recalculateETA()
    }

    manager.editingStyle(for: AddressETATableViewCell.self, { (_, _, _) -> UITableViewCellEditingStyle in .none })
    manager.editingStyle(for: ButtonTableViewCell.self, { (_, _, _) -> UITableViewCellEditingStyle in .none })
    manager.shouldIndentWhileEditing(AddressETATableViewCell.self, { (_, _, _) -> Bool in false })
    manager.shouldIndentWhileEditing(ButtonTableViewCell.self, { (_, _, _) -> Bool in false })
    
    manager.memoryStorage.setItemsForAllSections(cellModels())
  }
  
  private func setupAddAddressButton(_ button: UIButton) {
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .bringozOrange
    button.layer.cornerRadius = AddAddressButtonConfiguration.cornerRadius
    button.titleLabel?.font = AddAddressButtonConfiguration.font
  }
  
  // MARK: - Models
  private func cellModels() -> [[Any]] {
    var cellModels: [[Any]] = []
    
    addressesCellModels = addresses.enumerated().map { (index, element) -> AddressETATableViewCellModel in
      return self.addressETATableViewCellModel(for: element.address, previousAddressWithETA: addresses[safe: index - 1])
    }
    cellModels.append(addressesCellModels)
    
    let buttonCellModel = ButtonTableViewCellModel(title: "Add address")
    buttonCellModel.buttonPublishSubject.subscribe(onNext: { [weak self] () in
      self?.showSearchAddressController()
    }).disposed(by: disposeBag)
    cellModels.append([buttonCellModel])
    
    return cellModels
  }
  
  private func eta(for address: Address, previousAddressWithETA: AddressWithETA?) -> Date {
    guard let previousAddressWithETA = previousAddressWithETA else {
      return Date()
    }
    let timeInterval = distanceResolver.timeInterval(from: previousAddressWithETA.address,
                                                     to: address,
                                                     with: speed,
                                                     distanceType: .aerial)
    return previousAddressWithETA.eta.addingTimeInterval(timeInterval)
  }
  
  private func addressWithETA(for address: Address, previousAddressWithETA: AddressWithETA?) -> AddressWithETA {
    let eta = self.eta(for: address, previousAddressWithETA: previousAddressWithETA)
    return AddressWithETA(address: address, eta: eta)
  }
  
  private func addressETATableViewCellModel(for address: Address, previousAddressWithETA: AddressWithETA?) -> AddressETATableViewCellModel {
    let etaDate = self.eta(for: address, previousAddressWithETA: previousAddressWithETA)
    let eta = etaDateFormatter.string(from: etaDate)
    return AddressETATableViewCellModel(title: address.name, eta: eta)
  }
  
  // MARK: - NavigationBar buttons' actions
  private func resetData() {
    addresses = []
    addressesCellModels = []
    manager.memoryStorage.removeItems(fromSection: 0)
  }
  
  private func editButtonTapped() {
    tableView.isEditing = !tableView.isEditing
    if tableView.isEditing {
      editButton.title = "Done"
      navigationItem.setLeftBarButton(nil, animated: true)
    } else {
      editButton.title = "Edit"
      navigationItem.setLeftBarButton(removeButton, animated: true)
    }
  }
  
  // MARK: - Logic
  private func recalculateETA() {
    for (index, tuple) in zip(addresses, addressesCellModels).enumerated() {
      let (addressWithETA, cellModel) = tuple
      let eta = self.eta(for: addressWithETA.address, previousAddressWithETA: addresses[safe: index - 1])
      addressWithETA.eta = eta
      cellModel.etaBehaviorRelay.accept(etaDateFormatter.string(from: eta))
    }
  }
  
  private func moveModel(from: Int, to: Int) {
    do {
      let movedObject = addresses.remove(at: from)
      addresses.insert(movedObject, at: to)
    }
    
    do {
      let movedObject = addressesCellModels.remove(at: from)
      addressesCellModels.insert(movedObject, at: to)
    }
  }
  
  // MARK: - Actions
  private func addNewAddress(_ address: Address) {
    recalculateETA()
    
    let lastAddressWithETA = addresses.last
    let addressWithETA = self.addressWithETA(for: address, previousAddressWithETA: lastAddressWithETA)
    addresses.append(addressWithETA)
    
    let cellModel = addressETATableViewCellModel(for: address, previousAddressWithETA: lastAddressWithETA)
    addressesCellModels.append(cellModel)
    manager.memoryStorage.updateWithoutAnimations {
      manager.memoryStorage.addItem(cellModel, toSection: 0)
    }
    tableView.reloadData()
  }
  
  private func showSearchAddressController() {
    guard let navigationController = navigationController else {
      assertionFailure()
      return
    }
    let vc = SearchAddressViewController()
    vc.addressSelected.subscribe(onNext: { [weak self] (address) in
      self?.addNewAddress(address)
    }).disposed(by: disposeBag)
    navigationController.pushViewController(vc, animated: true)
  }
  
  private func bindModel(at index: Int, to model: AddressWithETA, rule: AddressBindingRule? = nil) {
    addresses[index].binder.bind(model, rule: rule)
    addressesCellModels[index].topBridgeViewHidden.accept(false)
    addressesCellModels[safe: index - 1]?.bottomBridgeViewHidden.accept(false)
  }
  
  private func unbindModel(at index: Int) {
    addresses[index].binder.unbind()
    addressesCellModels[index].topBridgeViewHidden.accept(true)
    addressesCellModels[safe: index - 1]?.bottomBridgeViewHidden.accept(true)
  }
}

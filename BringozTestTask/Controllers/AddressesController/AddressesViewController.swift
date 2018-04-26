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

fileprivate let cellBindedColor = UIColor.lightGray
fileprivate let cellDefaultColor = UIColor.clear

class AddressesViewController: TableViewController {
  
  // MARK: Properties
  var addresses: [AddressWithETA] = []
  var addressesCellModels: [AddressETATableViewCellModel] = []
  
  let speed = 10.0 // measured in m/sec
  
  let removeButton = UIBarButtonItem(title: "Reset", style: .plain, target: nil, action: nil)
  let editButton = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: nil)
  
  lazy var distanceResolver: DistanceResolver = CoreLocationDistanceResolver()
  
  lazy var etaDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, hh:mma"
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
      cell.buttonInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30)
      self?.setupAddAddressButton(cell.button)
    }
    
    manager.didSelect(AddressETATableViewCell.self) { [weak self] (cell, model, indexPath) in
      guard let wself = self else { return }
      
      let address = wself.addresses[indexPath.row]
      guard let previousAddress = wself.addresses[safe: indexPath.row - 1] else {
        address.binder.unbind()
        return
      }
      
      if address.binder.isBinded() {
        address.binder.unbind()
      } else {
        address.binder.bind(previousAddress, rule: nil)
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
      wself.addresses[sourceIndexPath.row].binder.unbind()
      wself.addresses[safe: sourceIndexPath.row + 1]?.binder.unbind()
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
    button.backgroundColor = .blue
    button.layer.cornerRadius = 5
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
}

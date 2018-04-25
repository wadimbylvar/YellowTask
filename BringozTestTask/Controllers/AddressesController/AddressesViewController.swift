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

class AddressesViewController: TableViewController {
  
  var addresses: [AddressWithETA] = []
  var addressCellModels: [AddressETATableViewCellModel] = []
  
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
    
    manager.register(AddressETATableViewCell.self)
    manager.register(ButtonTableViewCell.self)
    
    manager.configure(ButtonTableViewCell.self) { [weak self] (cell, model, indexPath) in
      cell.buttonInsets = UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30)
      self?.setupAddAddressButton(cell.button)
    }
    
    manager.canMove(AddressETATableViewCell.self) { (cell, model, indexPath) -> Bool in
      return true
    }
    manager.move(AddressETATableViewCell.self) { [weak self] (sourceIndexPath, cell, model, destinationIndexPath) in
      self?.manager.memoryStorage.moveItemWithoutAnimation(from: sourceIndexPath, to: destinationIndexPath)
    }

    manager.editingStyle(for: AddressETATableViewCell.self, { (_, _, _) -> UITableViewCellEditingStyle in .none })
    manager.editingStyle(for: ButtonTableViewCell.self, { (_, _, _) -> UITableViewCellEditingStyle in .none })
    manager.shouldIndentWhileEditing(AddressETATableViewCell.self, { (_, _, _) -> Bool in false })
    manager.shouldIndentWhileEditing(ButtonTableViewCell.self, { (_, _, _) -> Bool in false })
    
    manager.memoryStorage.setItemsForAllSections(cellModels())
  }
  
  private func cellModels() -> [[Any]] {
    var cellModels: [[Any]] = []
    
    let addressesCellModels = addresses.enumerated().map { (index, element) -> AddressETATableViewCellModel in
      return self.addressETATableViewCellModel(for: element, previousAddressWithETA: addresses[safe: index - 1])
    }
    cellModels.append(addressesCellModels)
    
    let buttonCellModel = ButtonTableViewCellModel(title: "Add address")
    buttonCellModel.buttonPublishSubject.subscribe(onNext: { [weak self] () in
      self?.showSearchAddressController()
    }).disposed(by: disposeBag)
    cellModels.append([buttonCellModel])
    
    return cellModels
  }
  
  private func addressETATableViewCellModel(for addressWithETA: AddressWithETA, previousAddressWithETA: AddressWithETA?) -> AddressETATableViewCellModel {
    let title = addressWithETA.address.name
    let etaDate: Date
    if let previousAddressWithETA = previousAddressWithETA {
      let timeInterval = distanceResolver.timeInterval(from: previousAddressWithETA.address,
                                                       to: addressWithETA.address,
                                                       with: speed,
                                                       distanceType: .aerial)
      etaDate = previousAddressWithETA.eta.addingTimeInterval(timeInterval)
    } else {
      etaDate = Date()
    }
    
    let eta = etaDateFormatter.string(from: etaDate)
    return AddressETATableViewCellModel(title: title, eta: eta)
  }
  
  private func setupAddAddressButton(_ button: UIButton) {
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .blue
    button.layer.cornerRadius = 5
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
  
  private func addNewAddress(_ address: Address) {
    let etaDate: Date
    if let lastAddressWithETA = addresses.last {
      let timeInterval = distanceResolver.timeInterval(from: lastAddressWithETA.address,
                                                       to: address,
                                                       with: speed,
                                                       distanceType: .aerial)
      etaDate = lastAddressWithETA.eta.addingTimeInterval(timeInterval)
    } else {
      etaDate = Date()
    }
    let addressWithETA = AddressWithETA(address: address, eta: etaDate)
    
    addresses.append(addressWithETA)
    
    let title = address.name
    let eta = etaDateFormatter.string(from: etaDate)
    let cellModel = AddressETATableViewCellModel(title: title, eta: eta)
    manager.memoryStorage.updateWithoutAnimations {
      manager.memoryStorage.addItem(cellModel, toSection: 0)
    }
    tableView.reloadData()
  }
  
  private func resetData() {
    addresses = []
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
}

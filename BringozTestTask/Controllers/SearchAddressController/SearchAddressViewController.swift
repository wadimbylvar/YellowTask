//
//  SearchAddressViewController.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DTTableViewManager

fileprivate let throttleInterval: RxTimeInterval = 0.3

fileprivate enum LabelCellConfiguration {
  static var labelInsets: UIEdgeInsets {
    return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
  }
}

// MARK: -
class SearchAddressViewController: TableViewController {
  
  // MARK: Properties
  @IBOutlet weak var searchBar: UISearchBar!
  
  var addressProvider: PresentableAddressProvider!
  
  let addressesBehaviorRelay = BehaviorRelay<[PresentableAddress]>(value: [])
  let addressSelected = PublishSubject<Address>()
  
  // MARK: - Life
  override func setupForm() {
    super.setupForm()
    
    title = LS("key.searchAddressViewController.addAddress")
    
    searchBar.becomeFirstResponder()
    searchBar.placeholder = LS("key.searchAddressViewController.search")
    searchBar.rx.text
      .skip(1)
      .throttle(throttleInterval, scheduler: SerialDispatchQueueScheduler(qos: .default))
      .flatMapLatest { [weak self] (text) -> Observable<[PresentableAddress]> in
        guard let wself = self else { return .empty() }
        guard let text = text, !text.isEmpty else {
          return .just([])
        }
        return wself.addressProvider.presentableAddresses(for: text)
      }
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] (addresses) in
        self?.addressesBehaviorRelay.accept(addresses)
      }).disposed(by: disposeBag)
  }
  
  override func setupTable() {
    super.setupTable()
    
    manager.register(LabelTableViewCell.self)
    
    manager.configure(LabelTableViewCell.self) { (cell, model, indexPath) in
      cell.labelInsets = LabelCellConfiguration.labelInsets
    }
    
    manager.didSelect(LabelTableViewCell.self) { [weak self] (cell, model, indexPath) in
      guard let wself = self else { return }
      wself.tableView.deselectRow(at: indexPath, animated: true)
      wself.select(presentableAddress: wself.addressesBehaviorRelay.value[indexPath.row])
    }
  }
  
  override func setupActions() {
    super.setupActions()
    
    addressesBehaviorRelay.subscribe(onNext: { [weak self] (presentableAddresses) in
      self?.updateTableView(presentableAddresses: presentableAddresses)
    }).disposed(by: disposeBag)
  }
  
  // MARK: - Actions
  private func updateTableView(presentableAddresses: [PresentableAddress]) {
    let models = presentableAddresses.map { LabelTableViewCellModel(text: $0.name) }
    manager.memoryStorage.setItems(models)
  }
  
  private func select(presentableAddress: PresentableAddress) {
    presentableAddress.address()
      .subscribe(onNext: { [weak self] (address) in
        guard let wself = self, let navigationController = wself.navigationController else { return }
        wself.addressSelected.onNext(address)
        navigationController.popViewController(animated: true)
      }).disposed(by: disposeBag)
  }
}

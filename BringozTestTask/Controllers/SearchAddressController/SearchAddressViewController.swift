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

class SearchAddressViewController: TableViewController {
  
  @IBOutlet weak var searchBar: UISearchBar!
  
  lazy var addressProvider: PresentableAddressProvider = GoogleAddressProvider()
  
  let addressesBehaviorRelay = BehaviorRelay<[PresentableAddress]>(value: [])
  let addressSelected = PublishSubject<Address>()
  
  // MARK: - Life
  override func setupForm() {
    super.setupForm()
    
    title = "Add address"
    
    searchBar.rx.text
      .skip(1)
      .throttle(0.3, scheduler: SerialDispatchQueueScheduler(qos: .default))
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
      cell.labelInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
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

//
//  TableViewController.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/24/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import DTTableViewManager

class TableViewController: UIViewController, DTTableViewManageable {
  
  var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    return refreshControl
  }()
  
  @IBOutlet weak var tableView: UITableView!
  
  // MARK: - Life
  override func viewDidLoad() {
    super.viewDidLoad()
    setupForm()
    setupTable()
    setupActions()
  }
  
  func setupForm() { }
  
  func setupTable() {
    manager.startManaging(withDelegate: self)
    tableView.sectionHeaderHeight = UITableViewAutomaticDimension
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedSectionHeaderHeight = 30
    tableView.estimatedRowHeight = 50
  }
  
  func setupActions() { }
}

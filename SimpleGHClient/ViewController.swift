//
//  ViewController.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 13/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit
import OctoKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let dataSource = ReposAndUsersTableViewDataSourceDelegate()
    private let networkingManager = NetworkingManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
        self.networkingManager.searchForUsersAndRepositories(keyword: "delphi") {
            objects, error in
            if let objects = objects {
                self.dataSource.objects = objects
                self.tableView.reloadData()
            } else {
                print("Error searching for users and repos: \(error)")
            }
        }
    }

}

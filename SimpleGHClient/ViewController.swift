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

    private let searchController = UISearchController(searchResultsController: nil)

    let dataSource = ReposAndUsersTableViewDataSourceDelegate()
    let networkingManager = NetworkingManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource

        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = searchController.searchBar
    }

}

extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text, keyword.characters.count > 0 else {
            self.dataSource.objects = []
            self.tableView.reloadData()
            return
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self)

        self.perform(#selector(self.performRemoteSearch(keyword:)), with: keyword, afterDelay: 1.5)
    }

    @objc private func performRemoteSearch(keyword : String) {
        self.networkingManager.searchForUsersAndRepositories(keyword: keyword) {
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

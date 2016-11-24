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

        self.definesPresentationContext = true

        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false

        self.tableView.tableHeaderView = searchController.searchBar
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userViewController = segue.destination as? UserViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = self.tableView.indexPath(for: cell) {
            userViewController.userObject = self.dataSource.userObject(atIndexPath: indexPath)
        }
    }

}

extension ViewController : UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text, keyword.characters.count > 0 else {
            self.dataSource.objects = []
            self.tableView.reloadData()
            return
        }

        // The code below limits calls to API - sends request only after user stops typing
        NSObject.cancelPreviousPerformRequests(withTarget: self)

        self.perform(#selector(self.performRemoteSearch(keyword:)), with: keyword, afterDelay: 1.5)
    }

    @objc private func performRemoteSearch(keyword : String) {
        self.networkingManager.searchForUsersAndRepositories(keyword: keyword) {
            result in
            switch result {
            case .data(let objects):
                self.dataSource.objects = objects
                self.tableView.reloadData()
            case .error(let error):
                self.dataSource.objects = []
                self.tableView.reloadData()
                print("Error searching for users and repos: \(error)")
            }
        }
    }
}

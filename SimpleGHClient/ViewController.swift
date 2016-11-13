//
//  ViewController.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 13/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit
import OctoKit

private let githubAPIURL = "https://api.github.com/v3"
private let repoCellReuseID = "RepoCellReuseID"
private let userCellReuseID = "UserCellReuseID"

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let client = OCTClient(server: OCTServer(baseURL: URL(string: githubAPIURL)))

    private var searchedRepositories : [OCTRepository] = []
    private var searchedUsers : [OCTUser] = []

    var searchedObjects : [OCTObject] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchForUsersAndRepositories(keyword: "Delphi")
    }

    private func searchForUsersAndRepositories(keyword: String) {

        let reposRequest = self.client?.searchRepositories(withQuery: keyword, orderBy: nil, ascending: false)

        let _ = reposRequest?.deliverOnMainThread().subscribeNext({ [weak self] (output) in
            guard let searchResult = output as? OCTRepositoriesSearchResult else {
                print("Invalid type of repository search output: \(output)")
                return
            }
            if let repos = searchResult.repositories as? [OCTRepository] {
                self?.searchedRepositories = repos
                self?.resetSearchedObjects()
            }

        }, error: { (error) in
            if let error = error {
                print("Error while fetching repositories: \(error)")
            }
        })

        let usersRequest = client?.searchUsers(withQuery: keyword, orderBy: nil, ascending: false)

        let _ = usersRequest?.deliverOnMainThread().subscribeNext({ [weak self] (output) in
            guard let searchResult = output as? OCTUsersSearchResult else {
                print("Invalid type of user search output: \(output)")
                return
            }
            if let users = searchResult.users as? [OCTUser] {
                self?.searchedUsers = users
                self?.resetSearchedObjects()
            }
        }, error: { (error) in
            if let error = error {
                print("Error while fetching users: \(error)")
            }
        })
    }

    private func resetSearchedObjects() {
        let searchedUsers : [OCTObject] = self.searchedUsers
        let searchedRepositories : [OCTObject] = self.searchedRepositories
        self.searchedObjects = (searchedUsers + searchedRepositories).sorted(by: { $0.objectID < $1.objectID })
    }


}

extension ViewController : UITableViewDelegate {
}

extension ViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.searchedObjects[indexPath.row]
        if let user = object as? OCTUser {
            let cell = tableView.dequeueReusableCell(withIdentifier: userCellReuseID, for: indexPath)
            cell.textLabel?.text = "User: \(user.name)"
            return cell
        }
        if let repo = object as? OCTRepository {
            let cell = tableView.dequeueReusableCell(withIdentifier: repoCellReuseID, for: indexPath)
            cell.textLabel?.text = "Repo: \(repo.name)"
            return cell
        }
        preconditionFailure("Unknown object type")
    }
}

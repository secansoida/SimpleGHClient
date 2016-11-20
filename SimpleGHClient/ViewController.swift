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

    var searchedObjects : [OCTObject] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchForUsersAndRepositories(keyword: "delphi")
    }

    private func searchForUsersAndRepositories(keyword: String) {

        let reposRequest = self.client?.searchRepositories(withQuery: keyword, orderBy: nil, ascending: false)

        let usersRequest = self.client?.searchUsers(withQuery: keyword, orderBy: nil, ascending: false)

        RACSignal.combineLatest([reposRequest, usersRequest] as NSFastEnumeration).deliverOnMainThread().subscribeNext({ (returnVal) in
            guard let dataTuple = returnVal as? RACTuple else {
                print("Error: invalid return type \(returnVal)")
                return
            }
            guard let reposSearchResult = dataTuple.first as? OCTRepositoriesSearchResult,
                let repos = reposSearchResult.repositories as? [OCTRepository] else {
                    print("Error: invalid repos return type \(dataTuple.first)")
                    return
            }
            guard let usersSearchResult = dataTuple.second as? OCTUsersSearchResult,
                let users = usersSearchResult.users as? [OCTUser] else {
                    print("Error: invalid users return type \(dataTuple.second)")
                    return
            }
            let userObjects : [OCTObject] = users
            let repositoryObjects : [OCTObject] = repos
            self.searchedObjects = (repositoryObjects + userObjects).sorted(by: { $0.objectID < $1.objectID })
        }, error: {
            print("Error: \($0)")
        })
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

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

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let client = OCTClient(server: OCTServer(baseURL: URL(string: githubAPIURL)))

    private let dataSource = ReposAndUsersTableViewDataSourceDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self.dataSource
        self.tableView.dataSource = self.dataSource
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
            self.dataSource.objects = (repositoryObjects + userObjects).sorted(by: { $0.objectID < $1.objectID })
            self.tableView.reloadData()
        }, error: {
            print("Error: \($0)")
        })
    }
}

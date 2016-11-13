//
//  ViewController.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 13/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit
import OctoKit

private let githubAPIURL = "https://api.github.com/v3";

class ViewController: UIViewController {

    private let client = OCTClient(server: OCTServer(baseURL: URL(string: githubAPIURL)))

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = client?.searchRepositories(withQuery: "SimpleGHClient", orderBy: nil, ascending: false)

        let _ = request?.deliverOnMainThread().subscribeNext({ (output) in
            guard let repos  = output as? OCTRepositoriesSearchResult else {
                print("OUTPUT: \(output)")
                return
            }
            print("REPOS COUNT: \(repos.repositories.count)")
        }, error: { (error) in
            if let error = error {
                print("ERROR \(error)")
            }
        })

        let usersRequest = client?.searchUsers(withQuery: "secansoida", orderBy: nil, ascending: false)

        let _ = usersRequest?.deliverOnMainThread().subscribeNext({ (output) in
            guard let usersResult  = output as? OCTUsersSearchResult else {
                print("OUTPUT: \(output)")
                return
            }
            print("users COUNT: \(usersResult.users.count)")
        }, error: { (error) in
            if let error = error {
                print("ERROR \(error)")
            }
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  UserViewController.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 20/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit
import OctoKit
import AFNetworking

class UserViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var starsCountLabel: UILabel!

    var userObject : OCTUser? {
        didSet {
            if self.isViewLoaded {
                self.setupWithUser()
            }
        }
    }

    var networkingManager : NetworkingManager? {
        didSet {
            if self.isViewLoaded {
                self.fetchUserData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithUser()

        self.fetchUserData()

        // TODO: display username, avatar, number of stars, number of followers
        // OCTClient -> fetchStarredRepositoriesForUser

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.followersCountLabel.layer.cornerRadius = self.followersCountLabel.frame.height / 2
        self.starsCountLabel.layer.cornerRadius = self.starsCountLabel.frame.height / 2
    }

    private func setupWithUser() {
        if let user = self.userObject {
            self.avatarImageView.setImageWith(user.avatarURL)

            self.usernameLabel.text = user.name

            self.followersCountLabel.text = "\(user.followers)"
        }
    }

    private func fetchUserData() {
        guard let user = self.userObject else {
            return;
        }
        self.networkingManager?.fetchUserData(forUser: user, completion: { [weak self] (result) in
            switch result {
            case .data(let user):
                self?.userObject = user
            case .error(let error):
                print("Error fetching user data: \(error)")
            }
        })

        self.networkingManager?.fetchNumberOfUserStarredRepositories(forUser: user) { [weak self] (result) in
            switch result {
            case .data(let numberOfStarredRepos):
                self?.starsCountLabel.text = "\(numberOfStarredRepos)"
            case .error(let error):
                print("Error fetching user data: \(error)")
            }
        }
    }

}

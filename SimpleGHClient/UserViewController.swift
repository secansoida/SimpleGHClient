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

    public var userObject : OCTUser?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.avatarImageView.setImageWith(self.userObject?.avatarURL)

        self.usernameLabel.text = self.userObject?.name

        // TODO: display username, avatar, number of stars, number of followers
        // OCTClient -> fetchStarredRepositoriesForUser

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

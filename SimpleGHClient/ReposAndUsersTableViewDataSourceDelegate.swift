//
//  ReposAndUsersTableViewDataSourceDelegate.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 20/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import UIKit
import OctoKit

private let repoCellReuseID = "RepoCellReuseID"
private let userCellReuseID = "UserCellReuseID"

// TODO: think of some better name...
class ReposAndUsersTableViewDataSourceDelegate: NSObject {
    public var objects : [OCTObject] = []

    public func userObject(atIndexPath indexPath: IndexPath) -> OCTUser? {
        if indexPath.row < self.objects.count {
            if let user = self.objects[indexPath.row] as? OCTUser {
                return user
            }
        }
        return nil
    }
}

extension ReposAndUsersTableViewDataSourceDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ReposAndUsersTableViewDataSourceDelegate : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.objects[indexPath.row]
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

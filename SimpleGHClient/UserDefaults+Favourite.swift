//
//  UserDefaults+Favourite.swift
//  SimpleGHClient
//
//  Created by justyna on 06/12/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import Foundation
import OctoKit

private let favouriteUsersKey = "favourite_users"

extension UserDefaults {

    func addUserToFavourites(user : OCTUser) {
        let data = NSKeyedArchiver.archivedData(withRootObject: user)
    
        if let savedUsers = self.favouriteUsersData() {
            self.set([data] + savedUsers, forKey: favouriteUsersKey)
        } else {
            self.set([data], forKey: favouriteUsersKey)
        }
    }
    
    func removeUserFromFavourites(user : OCTUser) {
        self.set(self.favouriteUsers().filter{ $0.objectID != user.objectID }.flatMap{ MTLJSONAdapter.jsonDictionary(from: $0)}, forKey: favouriteUsersKey)
    }
    
    func favouriteUsersData() -> [Data]? {
        if let favouriteUsersData = self.object(forKey: favouriteUsersKey) as? [Data] {
            return favouriteUsersData
        }
        return nil
    }
    
    func favouriteUsers() -> [OCTUser] {
        return self.favouriteUsersData()?.flatMap { NSKeyedUnarchiver.unarchiveObject(with: $0) as? OCTUser } ?? []
    }
    
    func isUserFavourite(user : OCTUser) -> Bool {
        return self.favouriteUsers().reduce(false) {
            acc, favouriteUser in
            if acc || user.objectID == favouriteUser.objectID {
                return true
            }
            return false
        }
    }
}

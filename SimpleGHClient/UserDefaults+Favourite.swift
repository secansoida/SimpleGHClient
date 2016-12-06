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
        guard let json = MTLJSONAdapter.jsonDictionary(from: user) else {
            return
        }
    
        if let savedUsers = self.favouriteUsersJSONs() {
            self.set([json] + savedUsers, forKey: favouriteUsersKey)
        } else {
            self.set([json], forKey: favouriteUsersKey)
        }
    }
    
    func favouriteUsersJSONs() -> [[AnyHashable : Any]]? {
        if let favouriteUsersJSONs = self.object(forKey: favouriteUsersKey) as? [[AnyHashable : Any]] {
            return favouriteUsersJSONs
        }
        return nil
    }
    
    func favouriteUsers() -> [OCTUser] {
        return self.favouriteUsersJSONs()?.flatMap {
            if let user = try? MTLJSONAdapter.model(of: OCTUser.self, fromJSONDictionary: $0, error: ()) as? OCTUser {
                return user
            }
        return nil
        } ?? []
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

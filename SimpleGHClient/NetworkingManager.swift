//
//  NetworkingManager.swift
//  SimpleGHClient
//
//  Created by Justyna Dolińska on 20/11/16.
//  Copyright © 2016 secansoida. All rights reserved.
//

import Foundation
import OctoKit

private let githubAPIURL = "https://api.github.com/v3"

public enum NetworkError : Error {
    case invalidReturnType(String)
}

class NetworkingManager {

    private let client = OCTClient(server: OCTServer(baseURL: URL(string: githubAPIURL)))

    public func searchForUsersAndRepositories(keyword: String, completion : (([OCTObject]?, Error?) -> Void)?) {

        let reposRequest = self.client?.searchRepositories(withQuery: keyword, orderBy: nil, ascending: false)

        let usersRequest = self.client?.searchUsers(withQuery: keyword, orderBy: nil, ascending: false)

        RACSignal.combineLatest([reposRequest, usersRequest] as NSFastEnumeration).deliverOnMainThread().subscribeNext({ (returnVal) in
            guard let completion = completion else {
                return
            }
            guard let dataTuple = returnVal as? RACTuple else {
                completion(nil, NetworkError.invalidReturnType("Expected RACTuple; Got: \(returnVal)"))
                return
            }
            guard let reposSearchResult = dataTuple.first as? OCTRepositoriesSearchResult,
                let repos = reposSearchResult.repositories as? [OCTRepository] else {
                    completion(nil, NetworkError.invalidReturnType("Expected OCTRepositoriesSearchResult; Got: \(dataTuple.first)"))
                    return
            }
            guard let usersSearchResult = dataTuple.second as? OCTUsersSearchResult,
                let users = usersSearchResult.users as? [OCTUser] else {
                    completion(nil, NetworkError.invalidReturnType("Expected OCTUsersSearchResult; Got: \(dataTuple.second)"))
                    return
            }
            let userObjects : [OCTObject] = users
            let repositoryObjects : [OCTObject] = repos

            let objects = (repositoryObjects + userObjects).sorted(by: { $0.objectID < $1.objectID })
            completion(objects, nil)
        }, error: {
            if let completion = completion {
                completion(nil, $0)
            }
        })
    }

}

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

enum NetworkError : Error {
    case invalidReturnType(String)
    case internalError(Error?)
}

enum Result<T> {
    case data(T)
    case error(NetworkError)
}

class NetworkingManager {

    private let client = OCTClient(server: OCTServer(baseURL: URL(string: githubAPIURL)))

    func searchForUsersAndRepositories(keyword: String, completion: @escaping (Result<[OCTObject]>) -> Void) {

        let reposRequest = self.client?.searchRepositories(withQuery: keyword, orderBy: nil, ascending: false)

        let usersRequest = self.client?.searchUsers(withQuery: keyword, orderBy: nil, ascending: false)

        RACSignal.combineLatest([reposRequest, usersRequest] as NSFastEnumeration).deliverOnMainThread().subscribeNext({ (returnVal) in

            guard let dataTuple = returnVal as? RACTuple else {
                completion(.error(.invalidReturnType("Expected RACTuple; Got: \(returnVal ?? "nil")")))
                return
            }
            guard let reposSearchResult = dataTuple.first as? OCTRepositoriesSearchResult,
                let repos = reposSearchResult.repositories as? [OCTRepository] else {
                    completion(.error(.invalidReturnType("Expected OCTRepositoriesSearchResult; Got: \(dataTuple.first)")))
                    return
            }
            guard let usersSearchResult = dataTuple.second as? OCTUsersSearchResult,
                let users = usersSearchResult.users as? [OCTUser] else {
                    completion(.error(.invalidReturnType("Expected OCTUsersSearchResult; Got: \(dataTuple.second)")))
                    return
            }
            let userObjects : [OCTObject] = users
            let repositoryObjects : [OCTObject] = repos

            let objects = (repositoryObjects + userObjects).sorted(by: { $0.objectID < $1.objectID })
            completion(.data(objects))
        }, error: {
            completion(.error(.internalError($0)))
        })
    }

    func fetchUserData(forUser user: OCTUser, completion: @escaping (Result<OCTUser>) -> Void) {

        let userRequest = self.client?.fetchUserInfo(for: user)

        let _ = userRequest?.deliverOnMainThread().subscribeNext({ (returnVal) in
            guard let user = returnVal as? OCTUser else {
                completion(.error(.invalidReturnType("Expected OCTUser; Got: \(returnVal ?? "nil")")))
                return
            }
            completion(.data(user))
        }, error: {
            completion(.error(.internalError($0)))
        })
    }

    func fetchNumberOfUserStarredRepositories(forUser user: OCTUser, completion: @escaping (Result<Int>) -> Void) {
        let starredReposRequest = self.client?.fetchNumberOfStarredRepositories(for: user)

        let _ = starredReposRequest?.deliverOnMainThread().subscribeNext({ (returnVal) in
            guard let numberOfStarredRepos = returnVal as? NSNumber else {
                completion(.error(.invalidReturnType("Expected NSNumber; Got: \(returnVal ?? "nil")")))
                return
            }
            completion(.data(numberOfStarredRepos.intValue))
        }, error: {
            completion(.error(.internalError($0)))
        })
    }
}

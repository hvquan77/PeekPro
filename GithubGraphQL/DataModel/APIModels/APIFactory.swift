//
//  APIFactory.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

protocol ApiFactory {
    func createGraphQLClient() -> RepositoryClient?
}

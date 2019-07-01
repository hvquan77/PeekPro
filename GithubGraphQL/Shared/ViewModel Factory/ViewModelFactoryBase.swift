//
//  ViewModelFactoryBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

protocol ViewModelFactoryBase {
    func createGraphQLViewModel() -> RepositoryViewModelBase?
    func createGraphQLViewModel(limit: Int, queryString: String) -> RepositoryViewModelBase?
}

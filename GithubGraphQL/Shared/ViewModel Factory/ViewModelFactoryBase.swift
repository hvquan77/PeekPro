//
//  ViewModelFactoryBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

protocol ViewModelFactoryBase {
    /**
     Create a default GraphQL View Model
     - returns: a RepositoryViewModel object
     */
    func createGraphQLViewModel() -> RepositoryViewModelBase?
    
    /**
     Create a custom GraphQL View Model
     - parameter limit:         maximum number of results/edges per fetch
     - parameter queryString:   query string to search for
     
     - returns: a RepositoryViewModel object
     */
    func createGraphQLViewModel(limit: Int, queryString: String) -> RepositoryViewModelBase?
}

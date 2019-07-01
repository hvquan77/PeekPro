//
//  ViewModelFactory.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class ViewModelFactory : ViewModelFactoryBase {
    func createGraphQLViewModel() -> RepositoryViewModelBase? {
        return GraphQLViewModel()
    }
    
    func createGraphQLViewModel(limit: Int, queryString: String) -> RepositoryViewModelBase? {
        return GraphQLViewModel(limit: limit, queryString: queryString)
    }
}

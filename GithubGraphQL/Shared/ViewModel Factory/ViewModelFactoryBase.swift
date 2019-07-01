//
//  ViewModelFactoryBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

class ViewModelFactoryBase : ViewModelFactory {
    func createGraphQLViewModel() -> RepositoryViewModel? {
        return GraphQLViewModel()
    }
}

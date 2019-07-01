//
//  GraphQLViewModel.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//
import UIKit
import Foundation

class GraphQLViewModel : RepositoryViewModelBase {
    private let defaultLimit = 35
    private let defaultQueryString = "graphql"
    
    override init() {
        super.init(limit: self.defaultLimit, queryString: self.defaultQueryString)
    }
    
    override init(limit: Int, queryString: String) {
        super.init(limit: limit, queryString: queryString)
    }
}

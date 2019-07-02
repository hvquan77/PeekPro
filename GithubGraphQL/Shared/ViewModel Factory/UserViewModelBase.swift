//
//  UserViewModelBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 7/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

/// A GitHubb Search View Model that is tailored for searching users
class UserViewModelBase : SearchGitViewModelBase {
    private let defaultLimit = 10
    private let defaultQueryString = "someone"
    private let defaultSearchType = SearchType.user
    
    override init() {
        super.init(limit: self.defaultLimit, queryString: self.defaultQueryString, searchType: self.defaultSearchType)
    }
    
    init(limit: Int, queryString: String) {
        super.init(limit: limit, queryString: queryString, searchType: self.defaultSearchType)
    }
    
    override func buildEdges(startIndex: Int = 0, data: SearchRepositoriesQuery.Data?, success: () -> Void, failure: (Error) -> Void) {
        assert(false, "\(String (describing: UserViewModelBase.self)) not yet implemented)")
    }
}

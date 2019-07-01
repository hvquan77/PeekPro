//
//  RepositoryViewModel.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

protocol RepositoryViewModel {
    var pageInfos: [PageInfo] { get }
    var edges: [Edge] { get }
    // and more
    
    func fetchAndSave(after: String?, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void))
    
    func syncFromCache(completion: () -> Void)
}

// TODO: Something we want to extend?
extension RepositoryViewModel {
    
}

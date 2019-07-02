//
//  RepositoryViewModelBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

/// A GitHubb Search View Model that is tailored for searching repositories
class RepositoryViewModelBase : SearchGitViewModelBase {
    private let defaultLimit = 10
    private let defaultQueryString = "repositorySample"
    private let defaultSearchType = SearchType.repository
    
    override init() {
        super.init(limit: self.defaultLimit, queryString: self.defaultQueryString, searchType: self.defaultSearchType)
    }
    
    init(limit: Int, queryString: String) {
        super.init(limit: limit, queryString: queryString, searchType: self.defaultSearchType)
    }
    
    override func buildEdges(startIndex: Int = 0, data: SearchRepositoriesQuery.Data?, success: () -> Void, failure: (Error) -> Void) {
        do
        {
            let edges = try self.context.fetch(Edge.fetchRequest(queryString: self.queryString, isAscending: true))
            if let count =  data?.search.edges?.count {
                for itemIndex in 0..<count {
                    var edge: Edge?
                    guard let gqlEdge = data?.search.edges?[itemIndex] else { continue }
                    guard let repository = gqlEdge.node?.asRepository?.fragments.repositoryDetails else { continue }
                    
                    if edges.count > itemIndex + startIndex {
                        edge = edges[itemIndex + startIndex]
                        print( "Edge \(edge?.name ?? "") found" )
                    } else {
                        print( "Edge \(repository.name) NOT found**" )
                        edge = Edge(entity: Edge.entity(), insertInto: self.context)
                        print("Edge \(repository.name) Info created")
                    }
                    
                    edge?.queryString = self.queryString
                    edge?.order = Int32(itemIndex + startIndex)
                    edge?.name = repository.name
                    edge?.url = repository.url
                    edge?.login = repository.owner.login
                    edge?.avatarUrl = repository.owner.avatarUrl
                    edge?.stargazersTotalCount = Int32(repository.stargazers.totalCount)
                    edge?.ownerType = repository.owner.__typename
                    edge?.typeName = repository.__typename
                }
            }
            self.appDelegate.saveContext()
            success()
        } catch let error as NSError {
            print("Unexpected error: \(error)")
            failure(error)
        }
    }
}

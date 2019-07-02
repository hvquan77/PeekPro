//
//  RepositoryViewModelBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

protocol SearchRepository {
    var limit: Int { get set}
    var queryString: String { get set }
    var searchType: SearchType { get }
    var pageInfos: [PageInfo] { get }
    var edges: [Edge] { get }
    
    func fetchAndSave(startIndex: Int, after: String?, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void))
    
    func syncFromCache(completion: () -> Void)
    
    func removeAllCache()
}

class RepositoryViewModelBase : SearchRepository {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var gqlQuery: SearchRepositoriesQuery
    var limit = 5
    var queryString = ""
    let searchType = SearchType.repository
    var edges = [Edge]()
    var pageInfos = [PageInfo]()
    
    init() {
        self.gqlQuery = SearchRepositoriesQuery.init(first: self.limit, query: self.queryString, type: self.searchType)
    }
    
    init(limit: Int, queryString: String) {
        self.limit = limit
        self.queryString = queryString
        self.gqlQuery = SearchRepositoriesQuery.init(first: limit, query: queryString, type: self.searchType)
    }
    
    func fetchAndSave(startIndex: Int = 0, after: String? = nil, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        self.setupQuery(limit: self.limit, after: after, queryString: self.queryString, type: self.searchType)
        
        RepositoriesGraphQLClient.searchRepositories(query: self.gqlQuery) { (result) in
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    print("Beginning fetchAndSave...")
                    self.buildPageInfo(data: gqlResult.data)
                    self.buildEdges(startIndex: startIndex, data: gqlResult.data, success: success, failure: failure)
                }
            case .failure(let error):
                if let error = error {
                    failure(error)
                }
            }
        }
    }
    
    func syncFromCache(completion: () -> Void ) {
        do {
            self.edges = try context.fetch(Edge.fetchRequest(queryString: self.queryString, isAscending: true))
            self.pageInfos = try context.fetch(PageInfo.fetchRequest())
            completion()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    private func setupQuery(limit: Int, after: String? = nil, queryString: String, type: SearchType) {
        self.limit = limit
        self.queryString = queryString
        self.gqlQuery = SearchRepositoriesQuery.init(first: limit, after: after, query: queryString, type: self.searchType)
    }
    
    private func buildPageInfo(data: SearchRepositoriesQuery.Data?) {
        if let pageInfoData = data?.search.pageInfo {
            do
            {
                let pageInfos = try self.context.fetch(PageInfo.fetchRequest())
                
                if let pageInfo = pageInfos.first as? PageInfo {
                    print("pageInfo found")
                    pageInfo.queryString = self.queryString
                    pageInfo.typeName = pageInfoData.__typename
                    pageInfo.endCursor = pageInfoData.endCursor
                    pageInfo.startCursor = pageInfoData.startCursor
                    pageInfo.hasNextPage = pageInfoData.hasNextPage
                    pageInfo.hasPreviousPage = pageInfoData.hasPreviousPage
                } else {
                    print("pageInfo NOT found")
                    let pageInfo = PageInfo(entity: PageInfo.entity(), insertInto: self.context)
                    pageInfo.queryString = self.queryString
                    pageInfo.typeName = pageInfoData.__typename
                    pageInfo.endCursor = pageInfoData.endCursor
                    pageInfo.startCursor = pageInfoData.startCursor
                    pageInfo.hasNextPage = pageInfoData.hasNextPage
                    pageInfo.hasPreviousPage = pageInfoData.hasPreviousPage
                    self.appDelegate.saveContext()
                }
                print("Page Info imported")
                print("")
            } catch let error as NSError {
                print("Unexpected error: \(error)")
            }
        }
    }
    
    private func buildEdges(startIndex: Int = 0, data: SearchRepositoriesQuery.Data?, success: () -> Void, failure: (Error) -> Void) {
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
    
    func removeAllCache() {
        do {
            let _ = try context.execute(Edge.batchDeleteRequest())
            let _ = try context.execute(PageInfo.batchDeleteRequest())
            print("Cleared all Core Data")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

//
//  SearchGitViewModelBase.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 7/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

protocol SearchRepository {
    var gqlQuery: SearchRepositoriesQuery {get set}
    var limit: Int { get set}
    var queryString: String { get set }
    var searchType: SearchType { get }
    var pageInfos: [PageInfo] { get }
    var edges: [Edge] { get }
    
    func fetchAndSave(startIndex: Int, after: String?, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void))
    
    func syncFromCache(completion: () -> Void)
    
    func removeAllCache()
}

class SearchGitViewModelBase : SearchRepository {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var gqlQuery: SearchRepositoriesQuery
    var limit = 5
    var queryString = ""
    var searchType = SearchType.repository
    var edges = [Edge]()
    var pageInfos = [PageInfo]()
    
    init() {
        self.gqlQuery = SearchRepositoriesQuery.init(first: self.limit, query: self.queryString, type: self.searchType)
    }
    
    init(limit: Int, queryString: String, searchType: SearchType) {
        self.limit = limit
        self.queryString = queryString
        self.searchType = searchType
        self.gqlQuery = SearchRepositoriesQuery.init(first: limit, query: queryString, type: self.searchType)
    }
    
    func fetchAndSave(startIndex: Int = 0, after: String? = nil, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        self.setupQuery(limit: self.limit, after: after, queryString: self.queryString, type: self.searchType)
        
        RepositoriesGraphQLClient.searchRepositories(query: self.gqlQuery) { (result) in
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    print()
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
    
    func setupQuery(limit: Int, after: String? = nil, queryString: String, type: SearchType) {
        self.limit = limit
        self.queryString = queryString
        self.gqlQuery = SearchRepositoriesQuery.init(first: limit, after: after, query: queryString, type: self.searchType)
    }
    
    func buildPageInfo(data: SearchRepositoriesQuery.Data?) {
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
    
    func buildEdges(startIndex: Int = 0, data: SearchRepositoriesQuery.Data?, success: () -> Void, failure: (Error) -> Void) {
        assert(false, "Subclass must override this function.")
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

//
//  GraphQLViewModel.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/30/19.
//  Copyright © 2019 test. All rights reserved.
//
import UIKit
import Foundation

class GraphQLViewModel : RepositoryViewModel {
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    private var gqlQuery: SearchRepositoriesQuery
    private let limit = 35 // TODO: add to protocol
    private let queryString = "graphql"  // TODO: add to protocol
    private let searchType = SearchType.repository  // TODO: to add to protocol
    internal var edges = [Edge]()
    internal var pageInfos = [PageInfo]()
    
    init() {
        self.gqlQuery = SearchRepositoriesQuery.init(first: self.limit, query: self.queryString, type: self.searchType)
    }

    func fetchAndSave(after: String? = nil, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        self.gqlQuery = SearchRepositoriesQuery.init(first: self.limit, after: after, query: self.queryString, type: self.searchType)
        
        RepositoriesGraphQLClient.searchRepositories(query: self.gqlQuery) { (result) in
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    if let pageInfoData = gqlResult.data?.search.pageInfo {
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
                            print("\n")
                        } catch let error as NSError {
                            print("Unexpected error: \(error)")
                        }
                    }
                    
                    do
                    {
                        let edges = try self.context.fetch(Edge.fetchRequest())
                        gqlResult.data?.search.edges?.forEach { gqlEdge in
                            guard let repository = gqlEdge?.node?.asRepository?.fragments.repositoryDetails else { return }
                            
                            if let edges = edges as? [Edge] {
                                if let index = edges.firstIndex(where: { $0.name == repository.name }) {
                                    print( "Edge \(edges[index].name ?? "") found" )
                                    edges[index].name = repository.name
                                    edges[index].url = repository.url
                                    edges[index].login = repository.owner.login
                                    edges[index].avatarUrl = repository.owner.avatarUrl
                                    edges[index].stargazersTotalCount = Int64(repository.stargazers.totalCount)
                                    edges[index].ownerType = repository.owner.__typename
                                    edges[index].typeName = repository.__typename
                                } else {
                                    print( "Edge \(repository.name) NOT found**" )
                                    let edge = Edge(entity: Edge.entity(), insertInto: self.context)
                                    edge.name = repository.name
                                    edge.url = repository.url
                                    edge.login = repository.owner.login
                                    edge.avatarUrl = repository.owner.avatarUrl
                                    edge.stargazersTotalCount = Int64(repository.stargazers.totalCount)
                                    edge.ownerType = repository.owner.__typename
                                    edge.typeName = repository.__typename
                                    print("Edge \(repository.name) Info imported")
                                }
                            }
                        }
                        
                        self.appDelegate.saveContext()
                        
                        success()
                    } catch let error as NSError {
                        print("Unexpected error: \(error)")
                    }
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
            self.edges = try context.fetch(Edge.fetchRequest())
            self.pageInfos = try context.fetch(PageInfo.fetchRequest())
            completion()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

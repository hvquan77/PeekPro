//
//  GraphQLTableViewController.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import CoreData

class GraphQLTableViewController: UITableViewController {
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var gqlQuery: SearchRepositoriesQuery?
    private let limit = 20
    //private var hasNextPage = true
    
    //private let refreshControl = UIRefreshControl()
    private var edges = [Edge]()
    private var pages = [PageInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App needs to be fast. So we'll fetch from cache if caches isn't empty.
        // User can then pull to refresh to get latest data.
        // If the cache is empty, only then will we call a fetchAndSave()
        self.setupGraphQLQuery()
        self.addRefreshControl()
        self.refresh()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pages.count + self.edges.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphGLSubtitleTableViewCell.name, for: indexPath)
        
        if let cell = cell as? GraphGLSubtitleTableViewCell {
            if indexPath.row == 0 {
                cell.title.text = self.pages[indexPath.row].typeName
                cell.details.text = """
                hasNextPage: \(self.pages[indexPath.row].hasNextPage)
                hasPreviousPage: \(self.pages[indexPath.row].hasPreviousPage)
                startCursor: \(self.pages[indexPath.row].startCursor ?? "")
                endCursor: \(self.pages[indexPath.row].endCursor ?? "")
                """
            } else {
                let newIndexPathRow = indexPath.row - 1
                cell.title.text = self.edges[newIndexPathRow].name ?? ""
                cell.details.text = """
                Path: \(self.edges[newIndexPathRow].url ?? "")
                Owner: \(self.edges[newIndexPathRow].login ?? "")
                Avatar: \(self.edges[newIndexPathRow].avatarUrl ?? "")
                Stars: \(self.edges[newIndexPathRow].stargazersTotalCount)
                """
            }
            
            return cell
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.edges.count - 4 {
            if self.pages.first?.hasNextPage ?? false {
                self.gqlQuery = SearchRepositoriesQuery.init(first: 20, after: self.pages.first?.endCursor ?? "", query: "graphql", type: SearchType.repository)
                self.fetchAndSaveGraphQLQuery()
            }
        }
    }

    // MARK: - setup
    // TODO: To add this to the data model
    private func setupGraphQLQuery() {
        //Initialize query
        self.gqlQuery = SearchRepositoriesQuery.init(first: 20, query: "graphql", type: SearchType.repository)
        
        // TODO: Paginated search Query
        //self.gqlQuery = SearchRepositoriesQuery.init(first: 5, after: "Y3Vyc29yOjEwMA==", query: "graphql", type: SearchType.repository)
    }
    
    private func addRefreshControl() {
        if self.refreshControl == nil {
            self.refreshControl = UIRefreshControl()
        }
        
        if let refreshControl = self.refreshControl {
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            refreshControl.addTarget(self,
                                     action: #selector(type(of: self).pullToRefresh),
                                     for: UIControl.Event.valueChanged)
            
            //refreshControl.attributedTitle = NSAttributedString(string: "Fetching GraphQL data...")
            refreshControl.attributedTitle = NSAttributedString(string: "Fetching GraphQL data...", attributes: attributes)
            refreshControl.tintColor = UIColor.white
            self.tableView.addSubview(refreshControl)
        }
    }
    
    private func fetchAndSaveGraphQLQuery() {
        if let query = self.gqlQuery {
            RepositoriesGraphQLClient.searchRepositories(query: query) { (result) in
                switch result {
                case .success(let data):
                    if let gqlResult = data {
                        if let pageInfoData = gqlResult.data?.search.pageInfo {
                            do
                            {
                                let pageInfos = try self.context.fetch(PageInfo.fetchRequest())
                                
                                if let pageInfo = pageInfos.first as? PageInfo {
                                    print("pageInfo found")
                                    pageInfo.queryString = "graphql"
                                    pageInfo.typeName = pageInfoData.__typename
                                    pageInfo.endCursor = pageInfoData.endCursor
                                    pageInfo.startCursor = pageInfoData.startCursor
                                    pageInfo.hasNextPage = pageInfoData.hasNextPage
                                    pageInfo.hasPreviousPage = pageInfoData.hasPreviousPage
                                } else {
                                    print("pageInfo NOT found")
                                    let pageInfo = PageInfo(entity: PageInfo.entity(), insertInto: self.context)
                                    pageInfo.queryString = "graphql"
                                    pageInfo.typeName = pageInfoData.__typename
                                    pageInfo.endCursor = pageInfoData.endCursor
                                    pageInfo.startCursor = pageInfoData.startCursor
                                    pageInfo.hasNextPage = pageInfoData.hasNextPage
                                    pageInfo.hasPreviousPage = pageInfoData.hasPreviousPage
                                    self.appDelegate.saveContext()
                                }
                                
                                //                                self.appDelegate.saveContext()
                                
                                print("Page Info imported")
                                print("\n")

                                //                        print("pageInfo \n")
                                //                        print("hasNextPage: \(pageInfo.hasNextPage)")
                                //                        print("hasPreviousPage: \(pageInfo.hasPreviousPage)")
                                //                        print("startCursor: \(String(describing: pageInfo.startCursor))")
                                //                        print("endCursor: \(String(describing: pageInfo.endCursor))")
                                //                        print("\n")
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
                                //                                print("Name: \(repository.name)")
                                //                                print("Path: \(repository.url)")
                                //                                print("Owner: \(repository.owner.login)")
                                //                                print("avatar: \(repository.owner.avatarUrl)")
                                //                                print("Stars: \(repository.stargazers.totalCount)")
                                //                                print("\n")
                            }
                            
                            self.appDelegate.saveContext()
                            
                            DispatchQueue.main.async {
                                self.refresh()
                            }
                        } catch let error as NSError {
                            print("Unexpected error: \(error)")
                        }
                    }
                case .failure(let error):
                    if let error = error {
                        print(error)
                    }
                }
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func refresh() {
        do {
            self.edges = try context.fetch(Edge.fetchRequest())
            self.pages = try context.fetch(PageInfo.fetchRequest())
            
            if self.edges.count == 0 {
                print("Empty state encountered")
                self.fetchAndSaveGraphQLQuery()
            } else {
                print("Pages count: \(self.pages.count)")
                print("Edges count: \(self.edges.count)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /**
     Trigger refresh on view model and show refresh animation
     */
    @objc func pullToRefresh() {
        self.setupGraphQLQuery()
        self.fetchAndSaveGraphQLQuery()
    }
    
    
    // MARK: TO DELETE
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
     
    // Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

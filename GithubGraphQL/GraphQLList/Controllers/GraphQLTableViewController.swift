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
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var edges = [Edge]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupGraphQLQuery()
        self.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refresh()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.edges.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphGLSubtitleTableViewCell.name, for: indexPath)
        
        if let cell = cell as? GraphGLSubtitleTableViewCell {
            cell.title.text = "Hang Quan"
            cell.details.text = "This is the details of my life"
            
            return cell
        }
        
        return cell
    }

    // MARK: - setup
    // TODO: To add this to the data model
    private func setupGraphQLQuery() {
        //Initialize query
        let gqlQuery = SearchRepositoriesQuery.init(first: 5, query: "graphql", type: SearchType.repository)
        
        // TODO: Paginated search Query
        //let gqlQuery = SearchRepositoriesQuery.init(first: 5, after: "Y3Vyc29yOjEwMA==", query: "graphql", type: SearchType.repository)
        
        RepositoriesGraphQLClient.searchRepositories(query: gqlQuery) { (result) in
            switch result {
            case .success(let data):
                if let gqlResult = data {
                    
                    if let pageInfo = gqlResult.data?.search.pageInfo {
                        
                        
                        print("pageInfo: \n")
                        print("hasNextPage: \(pageInfo.hasNextPage)")
                        print("hasPreviousPage: \(pageInfo.hasPreviousPage)")
                        print("startCursor: \(String(describing: pageInfo.startCursor))")
                        print("endCursor: \(String(describing: pageInfo.endCursor))")
                        print("\n")
                    }
                    
                    
                    gqlResult.data?.search.edges?.forEach { edge in
                        guard let repository = edge?.node?.asRepository?.fragments.repositoryDetails else { return }
                        print("Name: \(repository.name)")
                        print("Path: \(repository.url)")
                        print("Owner: \(repository.owner.login)")
                        print("avatar: \(repository.owner.avatarUrl)")
                        print("Stars: \(repository.stargazers.totalCount)")
                        print("\n")
                    }
                }
            case .failure(let error):
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    private func refresh() {
        do {
            self.edges = try context.fetch(Edge.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
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

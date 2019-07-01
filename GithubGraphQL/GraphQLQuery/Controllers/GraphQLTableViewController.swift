//
//  GraphQLTableViewController.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import CoreData

class GraphQLTableViewController : UIViewController {
    private var viewModel: RepositoryViewModel? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewModel()
        self.refresh()
    }

    // MARK: - Setup methods
    private func setupViewModel() {
        self.viewModel = ViewModelFactory().createGraphQLViewModel()
    }
    
    private func fetchAndSaveGraphQLQuery(after: String? = nil) {
        self.viewModel?.fetchAndSave(after: after, success: {
            DispatchQueue.main.async {
                self.refresh()
            }}, failure: { (error: Error) in
                print(error)
        })
    }
    
    private func refresh() {
        self.viewModel?.syncFromCache(completion: { return })
        
        if self.viewModel?.edges.count == 0 {
            print("Empty state encountered")
            self.fetchAndSaveGraphQLQuery()
        } else {
            print("Pages count: \(self.viewModel?.edges.count ?? 0)")
            print("Edges count: \(self.viewModel?.edges.count ?? 0)")
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
}

extension GraphQLTableViewController : UITableViewDelegate {
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.edges.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let edges = self.viewModel?.edges, indexPath.row == edges.count - 4 {
            if let first = self.viewModel?.pageInfos.first, first.hasNextPage {
                self.fetchAndSaveGraphQLQuery(after: first.endCursor ?? "")
            }
        }
    }
}

extension GraphQLTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphGLSubtitleTableViewCell.name, for: indexPath)
        
        if let cell = cell as? GraphGLSubtitleTableViewCell {
            if let edges = self.viewModel?.edges {
                cell.title.text = edges[indexPath.row].name ?? ""
                cell.details.text = """
                Path: \(edges[indexPath.row].url ?? "")
                Owner: \(edges[indexPath.row].login ?? "")
                Avatar: \(edges[indexPath.row].avatarUrl ?? "")
                Stars: \(edges[indexPath.row].stargazersTotalCount)
                """
            }
            
            return cell
            
        }
        
        return cell
    }
}

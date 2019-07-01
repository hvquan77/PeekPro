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
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewModel()
        self.addRefreshControl()
        self.refresh()
    }

    // MARK: - Setup methods
    private func setupViewModel() {
        self.viewModel = ViewModelFactory().createGraphQLViewModel()
    }
    
    private func addRefreshControl() {
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        refreshControl.addTarget(self,
                                 action: #selector(type(of: self).pullToRefresh),
                                 for: UIControl.Event.valueChanged)
        
        //refreshControl.attributedTitle = NSAttributedString(string: "Fetching GraphQL data...")
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching GraphQL data...", attributes: attributes)
        refreshControl.tintColor = UIColor.white
        self.tableView.addSubview(refreshControl)
    }
    
    private func fetchAndSaveGraphQLQuery(after: String? = nil) {
        self.viewModel?.fetchAndSave(after: after, success: {
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
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
    
    /**
     Trigger refresh on view model and show refresh animation
     */
    @objc func pullToRefresh() {
        self.setupViewModel()
        self.fetchAndSaveGraphQLQuery()
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

//
//  GraphQLTableViewController.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

/// The View Controller for GraphQL query
class GraphQLTableViewController : UITableViewController {
    private var viewModel: RepositoryViewModelBase? = nil
    private let lookAheadIndex = 5  // number of indeces to look ahead for Pagination
    private let cellHeight = 105
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPullToRefresh()
        self.refresh()
    }

    // MARK: - Setup methods
    private func setupViewModel() {
        self.viewModel = ViewModelFactory().createGraphQLViewModel()
    }
    
    private func setupPullToRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self,
                                  action: #selector(GraphQLTableViewController.pullToRefresh),
                                  for: UIControl.Event.valueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Fetching GraphQL data...")

        
        if let refreshControl = self.refreshControl {
            self.tableView?.addSubview(refreshControl)
        }
    }
    
    // MARK: - Private functions
    private func refresh() {
        self.viewModel?.syncFromCache(completion: { return })
        
        if self.viewModel?.edges.count == 0 {
            print("Empty state encountered")
            self.fetchAndSaveGraphQLQuery()
        } else {
            print("Pages count: \(self.viewModel?.pageInfos.count ?? 0)")
            print("Edges count: \(self.viewModel?.edges.count ?? 0)")
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    @objc private func pullToRefresh() {
        print("Pulled to refresh.")
        // BUG: App crashes when adding the following lines.
        // self.viewModel?.removeAllCache()
        // self.tableView?.reloadData()
        // self.refresh()
        
        self.fetchAndSaveGraphQLQuery()
    }
    
    private func fetchAndSaveGraphQLQuery(startIndex: Int = 0, after: String? = nil) {
        self.viewModel?.fetchAndSave(startIndex: startIndex, after: after, success: {
            DispatchQueue.main.async { [weak self] in
                self?.refreshControl?.endRefreshing()
                self?.refresh()
            }}, failure: { (error: Error) in
                print(error)
        })
    }

    // MARK: - UITableViewDelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.edges.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let edges = self.viewModel?.edges, indexPath.row == edges.count - self.lookAheadIndex {
            if let first = self.viewModel?.pageInfos.first, first.hasNextPage {
                self.fetchAndSaveGraphQLQuery(startIndex: edges.count, after: first.endCursor ?? "")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(self.cellHeight)
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphGLResultTableViewCell.name, for: indexPath)
        
        if let cell = cell as? GraphGLResultTableViewCell, let edges = self.viewModel?.edges {
            cell.setupCell(edge: edges[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let edges = self.viewModel?.edges,
            let gitUrl = edges[indexPath.row].url,
            let url = URL(string: gitUrl) {
            
            UIApplication.shared.open(url)
        }
        
        self.tableView?.deselectRow(at: indexPath, animated: true)
    }
}

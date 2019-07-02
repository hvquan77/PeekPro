//
//  GraphQLTableViewController.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class GraphQLTableViewController : UIViewController {
    private var viewModel: RepositoryViewModelBase? = nil
    private let lookAheadIndex = 5  // number of indeces to look ahead for Pagenation
    
    @IBOutlet weak var tableView: UITableView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refresh()
    }

    // MARK: - Setup methods
    private func setupViewModel() {
        self.viewModel = ViewModelFactory().createGraphQLViewModel()
    }
    
    private func fetchAndSaveGraphQLQuery(startIndex: Int? = 0, after: String? = nil) {
        self.viewModel?.fetchAndSave(startIndex: startIndex, after: after, success: {
            DispatchQueue.main.async {
                self.refresh()
            }}, failure: { (error: Error) in
                print(error)
        })
    }
    
    // MARK: - Private functions
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

// MARK: - UITableViewDelegate
extension GraphQLTableViewController : UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.edges.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let edges = self.viewModel?.edges, indexPath.row == edges.count - self.lookAheadIndex {
            if let first = self.viewModel?.pageInfos.first, first.hasNextPage {
                self.fetchAndSaveGraphQLQuery(startIndex: edges.count, after: first.endCursor ?? "")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(105)
    }
}

// MARK: - UITableViewDataSource
extension GraphQLTableViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GraphGLResultTableViewCell.name, for: indexPath)
        
        if let cell = cell as? GraphGLResultTableViewCell, let edges = self.viewModel?.edges {
            cell.setupCell(edge: edges[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let edges = self.viewModel?.edges,
            let gitUrl = edges[indexPath.row].url,
            let url = URL(string: gitUrl) {
            
            UIApplication.shared.open(url)
        }
        
        self.tableView?.deselectRow(at: indexPath, animated: true)
    }
}

//
//  GraphGLResultTableViewCell.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 7/1/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

/// Table View Cell for a GraphGL search result
class GraphGLResultTableViewCell: UITableViewCell {
    static let name = "graphGLResultCell"
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var logon: UILabel!
    
    /**
     Configures the GraphGLResultTableViewCell to display a repository.
     - parameter title:     name of the repository (optional)
     - parameter logon:     owner of the repository (optional)
     - parameter details:   description of the repository (optional)
     - parameter imageUrl:  url string of the author's avatar
     - parameter cout:      number of stars
     */
    public func setupCell(title: String? = "", logon: String? = "", details: String? = "", imageUrl: String, count: Int32) {
        self.title.text = title
        self.details.text = details
        self.logon.text = logon
        self.count.text = String(count)
        if let url = URL(string: imageUrl) {
            self.downloadImage(url: url)
        }
    }
    
    /**
     Configures the GraphGLResultTableViewCell to display a repository.
     - parameter edge:     Edge data object
     */
    public func setupCell(edge: Edge) {
        self.title.text = edge.name ?? ""
        self.details.text = edge.url ?? ""
        self.logon.text = edge.login ?? ""
        self.count.text = String(edge.stargazersTotalCount)
        if let imageUrl = edge.avatarUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
            self.downloadImage(url: url)
        }
    }
    
    /**
     Downloads and sets the avatar image
     - parameter url:  url of the avatar image
     */
    private func downloadImage(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.avatar.image = image
                    }
                }
            }
        }
    }
}

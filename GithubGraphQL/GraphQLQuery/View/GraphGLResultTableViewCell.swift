//
//  GraphGLResultTableViewCell.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 7/1/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class GraphGLResultTableViewCell: UITableViewCell {
    static let name = "graphGLResultCell"
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var logon: UILabel!
    
    public func setupCell(title: String? = "", logon: String? = "", details: String? = "", imageUrl: String, count: Int32) {
        self.title.text = title
        self.details.text = details
        self.logon.text = logon
        self.count.text = String(count)
        if let url = URL(string: imageUrl) {
            self.downloadImage(url: url)
        }
    }
    
    public func setupCell(edge: Edge) {
        self.title.text = edge.name ?? ""
        self.details.text = edge.url ?? ""
        self.logon.text = edge.login ?? ""
        self.count.text = String(edge.stargazersTotalCount)
        if let imageUrl = edge.avatarUrl, let url = URL(string: imageUrl), !imageUrl.isEmpty {
            self.downloadImage(url: url)
        }
    }
    
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

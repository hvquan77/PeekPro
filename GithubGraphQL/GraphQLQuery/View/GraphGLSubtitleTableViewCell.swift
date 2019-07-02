//
//  GraphGLSubtitleTableViewCell.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

/// Generic Table View Cell for a GraphGL search result
class GraphGLSubtitleTableViewCell: UITableViewCell {
    static let name = "graphGLSubtitleCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    
    /**
     Configures the GraphGLResultTableViewCell to display a repository.
     - parameter title:     name of the repository (optional)
     - parameter details:   description of the repository (optional)
     */
    public func setupCell(title: String? = "", details: String? = "") {
        self.title.text = title
        self.details.text = details
    }
}

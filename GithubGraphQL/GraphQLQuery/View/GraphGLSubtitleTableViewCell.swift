//
//  GraphGLSubtitleTableViewCell.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit

class GraphGLSubtitleTableViewCell: UITableViewCell {
    static let name = "graphGLSubtitleCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var details: UILabel!
    
    public func setupCell(title: String? = "", details: String? = "") {
        self.title.text = title
        self.details.text = details
    }
}

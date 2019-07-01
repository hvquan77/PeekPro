//
//  Edge+CoreDataClass.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


public class Edge: NSManagedObject {
    @nonobjc public class func fetchRequest(isAscending: Bool) -> NSFetchRequest<Edge> {
        let request = NSFetchRequest<Edge>(entityName: "Edge")
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Edge.order), ascending: isAscending)]
        
        return request
    }
}

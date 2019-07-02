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
    @nonobjc public class func fetchRequest(queryString: String, isAscending: Bool) -> NSFetchRequest<Edge> {
        let request = NSFetchRequest<Edge>(entityName: "Edge")
        let predicate = NSPredicate(format: "queryString == %@", queryString)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Edge.order), ascending: isAscending)]
        request.predicate = predicate
        
        return request
    }
    
    @nonobjc public class func batchDeleteRequest() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: Edge.fetchRequest())
    }
}

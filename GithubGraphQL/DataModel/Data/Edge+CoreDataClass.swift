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
    /**
     Fetch results of a particular query string in ascending/descending order
     - parameter queryString:       string to search for
     - parameter isAscending:       if true, then it's in ascending order
     
     - returns: data result collection
     */
    @nonobjc public class func fetchRequest(queryString: String, isAscending: Bool) -> NSFetchRequest<Edge> {
        let request = NSFetchRequest<Edge>(entityName: String(describing: Edge.self))
        let predicate = NSPredicate(format: "queryString == %@", queryString)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Edge.order), ascending: isAscending)]
        request.predicate = predicate
        
        return request
    }
    
    /**
     Batch delete all rows 
     */
    @nonobjc public class func batchDeleteRequest() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: Edge.fetchRequest())
    }
}

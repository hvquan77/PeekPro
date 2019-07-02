//
//  PageInfo+CoreDataClass.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


public class PageInfo: NSManagedObject {
    /**
     Fetch results of a particular query string
     - parameter queryString:       string to search for
     
     - returns: data result collection
     */
    @nonobjc public class func fetchRequest(queryString: String) -> NSFetchRequest<PageInfo> {
        let request = NSFetchRequest<PageInfo>(entityName: String(describing: PageInfo.self))
        let predicate = NSPredicate(format: "queryString == %@", queryString)
        request.predicate = predicate
        
        return request
    }
    
    /**
     Batch delete all rows
     */
    @nonobjc public class func batchDeleteRequest() -> NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: PageInfo.fetchRequest())
    }
}

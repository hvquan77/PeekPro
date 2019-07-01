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
    @nonobjc public class func fetchRequest(queryString: String) -> NSFetchRequest<PageInfo> {
        let request = NSFetchRequest<PageInfo>(entityName: "PageInfo")
        let predicate = NSPredicate(format: "queryString == %@", queryString)
        request.predicate = predicate
        
        return request
    }
}

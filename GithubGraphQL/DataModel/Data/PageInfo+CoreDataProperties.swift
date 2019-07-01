//
//  PageInfo+CoreDataProperties.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 6/29/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


extension PageInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PageInfo> {
        return NSFetchRequest<PageInfo>(entityName: "PageInfo")
    }

    @NSManaged public var endCursor: String?
    @NSManaged public var hasNextPage: Bool
    @NSManaged public var hasPreviousPage: Bool
    @NSManaged public var queryString: String?
    @NSManaged public var startCursor: String?
    @NSManaged public var typeName: String?

}

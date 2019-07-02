//
//  Edge+CoreDataProperties.swift
//  GithubGraphQL
//
//  Created by Hang Quan on 7/1/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Edge {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Edge> {
        return NSFetchRequest<Edge>(entityName: "Edge")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var login: String?
    @NSManaged public var name: String?
    @NSManaged public var order: Int32
    @NSManaged public var ownerType: String?
    @NSManaged public var stargazersTotalCount: Int32
    @NSManaged public var typeName: String?
    @NSManaged public var url: String?
    @NSManaged public var queryString: String?

}

//
//  CoreDataEntityItemViewController.swift
//
//  Copyright © 2019 Microsoft. All rights reserved.
//

import UIKit
import CoreData

/**
 View controller for viewing all items of an entity from CoreData
 */
class CoreDataEntityItemViewController: UIViewController {
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    static let coreDataEntityItemCellId = "CoreDataEntityItemCellId"
    static let coreDataEntityItemCellEstimatedRowHeight: CGFloat = 25
    
    var entityName: String?
    var entityItems = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = CoreDataEntityItemViewController.coreDataEntityItemCellEstimatedRowHeight
        
        if let entityName = self.entityName {
            self.populateEntityItems(entityName: entityName)
        }
    }
    
    /**
     Retrieve all items from the entity
     
     - parameter entityName: Entity to retrieve items from
     */
    private func populateEntityItems(entityName: String) {
        var entityItems = [[String:String]]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: entityName, in: self.managedContext)
        let results = try? self.managedContext.fetch(fetchRequest)
        let configs = results as? [NSManagedObject]
        configs?.forEach({ object in
            
            var entityItemProperites = [String:String]()
            
            object.entity.attributesByName.forEach({ (key, value) in
                
                if let className = value.attributeValueClassName {
                    entityItemProperites[key] = self.generateStringForValue(value: object.value(forKey: key), className: className)
                }
            })
            
            entityItems.append(entityItemProperites)
        })
        
        self.entityItems = entityItems
    }
    
    /**
     Generate a string for the value
     
     - parameter value: Value to generate a string for
     - parameter className: The type of the value
     
     - returns: The string of the value
     */
    private func generateStringForValue(value: Any?, className: String) -> String {
        var output = ""
        
        if className == "NSString" {
            output = value as? String ?? ""
        } else if className == "NSNumber" {
            let nsNumber = value as? NSNumber
            output = nsNumber?.stringValue ?? ""
        }
        
        return output
    }
}

/**
 UITableViewDataSource protocol methods
 */
extension CoreDataEntityItemViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entityItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoreDataEntityItemViewController.coreDataEntityItemCellId, for: indexPath)
        
        if let coreDataEntityItemCell = cell as? CoreDataEntityItemTableViewCell {
            var propertyString = ""
            let entityItemProperties = self.entityItems[indexPath.row]
            entityItemProperties.forEach { (key, value) in
                propertyString += "\(key): \(value) \n"
            }
            
            coreDataEntityItemCell.detailsLabel.text = propertyString
        }
        
        return cell
    }
}

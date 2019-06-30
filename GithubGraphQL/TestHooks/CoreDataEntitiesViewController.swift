//
//  CoreDataEntitiesViewController.swift
//
//  Copyright © 2019 Microsoft. All rights reserved.
//

import UIKit
import CoreData

/**
 View controller for viewing CoreData entities
 */
class CoreDataEntitiesViewController: UIViewController {
    private let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    static let coreDataEntityCellId = "CoreDataEntityCellId"
    static let showEntityItemSegue = "ShowEntityItemSegue"
    
    var entities = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.populateEntities()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    /**
     Retrieve all entities from CoreData
     */
    private func populateEntities() {
        let model = self.managedContext.persistentStoreCoordinator?.managedObjectModel
        model?.entities.forEach({ [weak self] entity in
            
            if NSEntityDescription.entity(forEntityName: entity.managedObjectClassName, in: self!.managedContext) != nil {
                self?.entities.append(entity.managedObjectClassName)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CoreDataEntitiesViewController.showEntityItemSegue,
            let coreDataEntityItemViewController = segue.destination as? CoreDataEntityItemViewController,
            let index = self.tableView.indexPathForSelectedRow {
            coreDataEntityItemViewController.entityName = self.entities[index.row]
        }
    }
}

/**
 UITableViewDataSource protocol methods
 */
extension CoreDataEntitiesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: CoreDataEntitiesViewController.coreDataEntityCellId)
        if (cell == nil) {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: CoreDataEntitiesViewController.coreDataEntityCellId)
        }
        
        if let cell = cell {
            cell.textLabel?.text = self.entities[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
}

/**
 UITableViewDelegate protocol methods
 */
extension CoreDataEntitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: CoreDataEntitiesViewController.showEntityItemSegue, sender: nil)
    }
}

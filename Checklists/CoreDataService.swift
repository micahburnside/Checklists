//
//  CoreDataService.swift
//  
//
//  Created by Micah Burnside on 03/24/23.
//
import UIKit
import Foundation
import CoreData

class CoreDataService: NSObject {

    static let shared: CoreDataService = {
        return CoreDataService()
    }()

    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Checklists")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Fail to load persistent stores \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func addCategory(with name: String) {
        let person = NSEntityDescription.insertNewObject(forEntityName: "Category", into: persistentContainer.viewContext)
        person.setValue(name, forKey: "name")
    }
    
    func removeCategory(with name: String) {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@")
        do {
            guard let category = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                // no item :(
                return
            }
            persistentContainer.viewContext.delete(category)
        } catch let error {
        print("Failed to delete category \(error)")
        }
        
    }
    
    func insertCategory(name: Any) {
        let category = Category(context: self.persistentContainer.viewContext)
        }
    
    func addItem(with name: String) {
        let person = NSEntityDescription.insertNewObject(forEntityName: "Item", into: persistentContainer.viewContext)
        person.setValue(name, forKey: "name")
    }
    
    func removeItem(with name: String) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@")
        do {
            guard let item = try persistentContainer.viewContext.fetch(fetchRequest).first else {
                // no item :(
                return
            }
            persistentContainer.viewContext.delete(item)
        } catch let error {
        print("Failed to delete category \(error)")
        }
        
    }

    
    func saveContext(backgroundContext: NSManagedObjectContext? = nil) {
        let context = backgroundContext ?? context
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error: \(error), \(error.userInfo)")
        }
    }
    func insertItem(name: Any) {
        let item = Item(context: self.persistentContainer.viewContext)
        }
        
        
}

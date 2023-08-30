//
//  ViewController.swift
//  Todoey
//
//  Created by Angela Yu on 16/11/2017.
//  Copyright © 2017 Angela Yu. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    let searchBar = UISearchBar()
    var items = [Item]()
    /// The table view used to display the list of contacts.
    let todoListTableView = UITableView()
    

    ///Creates a reference to the context from CoreDataService()
    let context = CoreDataService.shared.context
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }

    func setUpNavBarButtons() {
        let addRightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightHandAction))
//        let addLeftBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(leftHandAction))
        self.navigationItem.rightBarButtonItem = addRightBarButton
    }
    
    @objc func rightHandAction() {
        createNewItem()
        print("right bar button action")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableViewCell()
        

        
        // Disable autoresizing mask translation for the table view
        todoListTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints for the table view
        // This constraint sets the topAnchor of the contactsTableView to be equal to the topAnchor of the safeAreaLayoutGuide.
        todoListTableView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor).isActive = true
        // This constraint sets the leftAnchor of the contactsTableView to be equal to the leftAnchor of the safeAreaLayoutGuide.
        todoListTableView.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor).isActive = true
        // This constraint sets the rightAnchor of the contactsTableView to be equal to the rightAnchor of the safeAreaLayoutGuide.
        todoListTableView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor).isActive = true
        // This constraint sets the bottomAnchor of the contactsTableView to be equal to the bottomAnchor of the safeAreaLayoutGuide.
        todoListTableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
        
        // Sets the data source and delegate of the table view
        todoListTableView.dataSource = self
        todoListTableView.delegate = self
        

        // Set the view controller's title
        navigationItem.title = "Items"
        
        setUpSearchBar()
        // Calls setTableViewFrame to set the table view's frame
        setTableViewFrame()
        setUpNavBarButtons()
        loadItems()

        
    }
    func setUpTableViewCell() {
        // Register the custom contact cell
        todoListTableView.register(ToDoListTableViewCell.self, forCellReuseIdentifier: "ToDoListTableViewCell")
        // Add the todoListTableView to the view
        view.addSubview(todoListTableView)
    }
    
    // MARK: - SetUpTableView()
    func setUpTableView() {
        setTableViewFrame()
        
    }

    /// Sets the frame of the table view to be the same as the view controller's view.
    func setTableViewFrame() {
        todoListTableView.frame = self.view.frame
    }
    
    func setUpConstraints() {
        
    }
// MARK: - Search Bar

    func setUpSearchBar() {
        // Set up search bar
          searchBar.delegate = self
          searchBar.placeholder = "Search"
          searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Add search bar to container view
        let container = UIView()
        container.addSubview(searchBar)
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)
    }
// MARK: - CreateNewItem()

    func createNewItem() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory

            self.items.append(newItem)
            
            self.saveItems()
            
        }
        alert.addAction(cancelAction)
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new item"
        }
        
        present(alert, animated: true, completion: nil)
        todoListTableView.reloadData()
    }
// MARK: - Long Press Action

    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        // Get the cell that was long-pressed
        guard let cell = sender.view as? ToDoListTableViewCell else { return }

        // Get the index path of the cell
        guard let indexPath = todoListTableView.indexPath(for: cell) else { return }
        let item = items[indexPath.row]

        // Create the alert controller
        let alertController = UIAlertController(title: "Edit Item", message: "Enter new name and job title", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = item.title // Set the existing item title here
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            // Handle the save action here
            let itemTextField = alertController.textFields?[0]
            item.title = itemTextField?.text
            self.saveItems()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

//MARK: - Tableview Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListTableViewCell", for: indexPath) as! ToDoListTableViewCell
        // Add a long press gesture recognizer to the cell
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        cell.addGestureRecognizer(longPressRecognizer)

        let item = items[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        cell.textLabel?.text = item.title
        
        // set the tint color of the cell
        if item.done {
            cell.accessoryType = .checkmark
            cell.tintColor = .systemGreen
        } else {
            cell.accessoryType = .none
            cell.accessoryView = nil
        }

        return cell

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the person to be deleted
            let item = items[indexPath.row]
            
            // Delete the person from the managed object context
            context.delete(item)
            
            // Save the changes to Core Data
            saveItems()
            
            // Remove the person from the array and update the table view
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        items[indexPath.row].done = !items[indexPath.row].done

        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    
    //MARK - Model Manupulation Methods
    
    func saveItems() {
        
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        
        self.todoListTableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        
        do {
            items = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        todoListTableView.reloadData()
        
    }
    
}










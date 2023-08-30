//
//  CategoryViewController.swift
//  Todoey
//
//  Created by MicahBurnside 03/23/23.
//  Copyright ©MicahBurnside. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {
    
    var categories = [Category]()
    
    let context = CoreDataService.shared.context
    
    /// The table view used to display the list of contacts.
    let categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    func setTableViewFrame() {
        categoriesTableView.frame = self.view.frame
    }
    
    func registerCell() {
        
    }
    
    @objc func rightHandAction() {
        createNewCategory()
        print("right bar button action")
    }
    
    func setUpNavBarButtons() {
        let addRightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightHandAction))
        self.navigationItem.rightBarButtonItem = addRightBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
       self.title = "Categories"
        if let appearance = navigationController?.navigationBar.standardAppearance {
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            categoriesTableView.backgroundColor = .systemBackground
        }

        self.categoriesTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryTableViewCell")
        view.addSubview(categoriesTableView)

        configureCategoriesTableViewConstraints()
        // Sets the data source and delegate of the table view

        configureTableView()
        // Register the custom contact cell
//        categoriesTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryTableViewCell")
        // Set the view controller's title
        navigationItem.title = "Categories"
        // Calls setTableViewFrame to set the table view's frame
        setTableViewFrame()
        setUpNavBarButtons()
        loadCategories()

    }
    
    private func configureTableView() {
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
    }

    private func configureCategoriesTableViewConstraints() {
        // Set up constraints for the table view
        // This constraint sets the topAnchor of the contactsTableView to be equal to the topAnchor of the safeAreaLayoutGuide.
        categoriesTableView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor).isActive = true
        // This constraint sets the leftAnchor of the contactsTableView to be equal to the leftAnchor of the safeAreaLayoutGuide.
        categoriesTableView.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor).isActive = true
        // This constraint sets the rightAnchor of the contactsTableView to be equal to the rightAnchor of the safeAreaLayoutGuide.
        categoriesTableView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor).isActive = true
        // This constraint sets the bottomAnchor of the contactsTableView to be equal to the bottomAnchor of the safeAreaLayoutGuide.
        categoriesTableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
    }
    
    func loadNextView() {
        let controller = TodoListViewController()
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
//    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
//        // Get the cell that was long-pressed
//        guard let cell = sender.view as? CategoryTableViewCell else { return }
//        // Get the index path of the cell
//        guard let indexPath = categoriesTableView.indexPath(for: cell) else { return }
//
//        // Create the alert controller
//        let alertController = UIAlertController(title: "Edit Category", message: "Enter new category", preferredStyle: .alert)
//        alertController.addTextField { (textField) in
//            textField.placeholder = "New Category"
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
//            // Handle the save action here
//            let textField = alertController.textFields?[0]
//            let newCategory = self.categories[indexPath.row]
//            newCategory.name = textField?.text
//            self.saveCategories()
//        }
//        alertController.addAction(cancelAction)
//        alertController.addAction(saveAction)
//
//        // Present the alert controller
//        present(alertController, animated: true, completion: nil)
//    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        // Get the cell that was long-pressed
        guard let cell = sender.view as? CategoryTableViewCell else { return }
        // Get the index path of the cell
        guard let indexPath = categoriesTableView.indexPath(for: cell) else { return }
        let category = categories[indexPath.row]

        // Create the alert controller
        let alertController = UIAlertController(title: "Edit Category", message: "Enter new category", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = category.name // Set the existing category name here
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            // Handle the save action here
            let textField = alertController.textFields?[0]
            category.name = textField?.text
            self.saveCategories()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    



    //MARK: - Data Manipulation Methods
    func createNewCategory() {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categories.append(newCategory)
            
            self.saveCategories()
            
        }
        alert.addAction(cancelAction)
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(alert, animated: true, completion: nil)
        categoriesTableView.reloadData()
    }
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        
        categoriesTableView.reloadData()
        
    }
    
    func loadCategories() {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        do{
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
       
        categoriesTableView.reloadData()
        
    }
    
    
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath)
        // Add a long press gesture recognizer to the cell
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        cell.addGestureRecognizer(longPressRecognizer)
        
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
        
    }

    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Get the person to be deleted
            let category = categories[indexPath.row]
            
            // Delete the person from the managed object context
            CoreDataService.shared.context.delete(category)
            
            // Save the changes to Core Data
            saveCategories()
            
            // Remove the person from the array and update the table view
            categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = TodoListViewController()
        
        if let indexPath = categoriesTableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories[indexPath.row]
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}

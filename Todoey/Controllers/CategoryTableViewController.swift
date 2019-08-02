//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/30/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryTableViewController: UITableViewController {
    
    var categoryItems: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    // MARK: UITableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        let categoryName = categoryItems?[indexPath.row].categoryName ?? "No categories added yet"
        cell.textLabel?.text = categoryName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destination.parentCategory = categoryItems?[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    //MARK: Actions
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Category", message: "Please enter the name of your new category.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Category Name"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            
            guard let newCategoryName = alert.textFields![0].text else{
                fatalError("Category name text was unavailable")
            }
            
            let newCategory = Category()
            newCategory.categoryName = newCategoryName
            
            self.save(category: newCategory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func loadCategories(){
        categoryItems = realm.objects(Category.self)
    }
    
    private func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        } catch{
            print("Error saving categories: \(error)")
        }
        
        tableView.reloadData()
    }
    
}

//MARK: - Swipe Cell Delegate Methods
extension CategoryTableViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else{ return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: nil) {
            (action, indexPath) in
            
            if let category = self.categoryItems?[indexPath.row]{
                do{
                    try self.realm.write {
                        self.realm.delete(category)
                    }
                } catch{
                    print("Error deleting category \(category): \(error)")
                }
            }
        }
        
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

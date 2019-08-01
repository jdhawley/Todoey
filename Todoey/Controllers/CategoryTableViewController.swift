//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/30/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryTableViewController: UITableViewController {
    
    var categoryItems = [Category]()
    var selectedCategory: Category?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
        return categoryItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let categoryName = categoryItems[indexPath.row].categoryName
        
        cell.textLabel?.text = categoryName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCategory = categoryItems[indexPath.row]
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        
        destination.parentCategory = selectedCategory
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
            
            self.categoryItems.append(newCategory)
            self.save(category: newCategory)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func loadCategories(){
//        let request: NSFetchRequest<Category> = Category.fetchRequest()
//
//        do{
//            categoryItems = try context.fetch(request)
//        } catch{
//            print("Error reading categories: \(error)")
//        }
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

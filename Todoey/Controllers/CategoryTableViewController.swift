//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/30/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    var categoryItems: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let color = UIColor.flatSkyBlue
        navigationController?.navigationBar.barTintColor = color
        navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)]
        
    }

    // MARK: UITableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let category = categoryItems?[indexPath.row] else{ fatalError("IndexPath out of range.") }
        
        cell.textLabel?.text = category.categoryName
        cell.backgroundColor = UIColor(hexString: category.backgroundColor)
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        
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
            newCategory.backgroundColor = UIColor.randomFlat.hexValue()
            
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
    
    
    //MARK: Delete from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let category = categoryItems?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(category)
                }
            } catch{
                print("Error deleting category \(category): \(error)")
            }
        }
    }
}

//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/25/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {
    let realm = try! Realm()
    
    var todoItems: Results<TodoItem>?
    var parentCategory: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }

    //MARK: TableView Delegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        if let todo = todoItems?[indexPath.row]{
            cell.textLabel?.text = todo.todoText
            cell.accessoryType = todo.isComplete ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No items added"
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleComplete(indexPath: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Todo", message: "Please enter your todo item below.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            guard let todoText = alert.textFields?[0].text
                else{ fatalError("Todo text was unavailable") }
            
            if let currentCategory = self.parentCategory{
                do{
                    try self.realm.write {
                        let item = TodoItem()
                        item.todoText = todoText
                        currentCategory.todoItems.append(item)
                    }
                } catch{
                    print("Error saving realm: \(error)")
                }
            }
            
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (textField) in
            textField.placeholder = "Todo Item"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Private Functions
    private func toggleComplete(indexPath: IndexPath){
        guard let cell = tableView.cellForRow(at: indexPath) else{ fatalError("IndexPath out of range") }

        if let todo = todoItems?[indexPath.row]{
            todo.isComplete = !todo.isComplete
        }
        
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
    }
    
    private func loadItems(){
        todoItems = parentCategory?.todoItems.sorted(byKeyPath: "todoText", ascending: true)
    }
}

//extension TodoListViewController: UISearchBarDelegate{
//
//    //MARK: SearchBar Delegate Methods
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
//
//        request.predicate = NSPredicate(format: "todoText CONTAINS[cd] %@", searchBar.text ?? "")
//        request.sortDescriptors = [NSSortDescriptor(key: "todoText", ascending: true)]
//
//        loadItems(withRequest: request)
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if (searchBar.text ?? "").count == 0{
//            loadItems(forCategory: parentCategory!.categoryName!)
//
//            DispatchQueue.main.async {
//                searchBar.resignFirstResponder()
//            }
//        }
//    }
//}

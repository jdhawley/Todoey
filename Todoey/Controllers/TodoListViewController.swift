//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/25/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    var parentCategory: Category?
    var itemArray = [TodoItem]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems(forCategory: parentCategory!.categoryName!)
    }

    //MARK: TableView Delegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todo = itemArray[indexPath.row]
        
        cell.textLabel?.text = todo.todoText
        cell.accessoryType = todo.isComplete ? .checkmark : .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
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
            
            let item = TodoItem(context: self.context)
            item.todoText = todoText
            item.isComplete = false
            item.parentCategory = self.parentCategory
            self.itemArray.append(item)
            
            self.saveData()
            
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
        let todo = itemArray[indexPath.row]
        
        todo.isComplete = !todo.isComplete
        
        saveData()
        
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
    }
    
    private func saveData(){
        do{
            try context.save()
        } catch{
            print("Error saving context: \(error)")
        }
    }
    
    private func loadItems(forCategory categoryName: String){
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.predicate = NSPredicate(format: "ANY parentCategory.categoryName == %@", categoryName)
        
        loadItems(withRequest: request)
    }
    
    private func loadItems(withRequest request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()){
        do{
            itemArray = try context.fetch(request)
        } catch{
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
}

extension TodoListViewController: UISearchBarDelegate{
    
    //MARK: SearchBar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        request.predicate = NSPredicate(format: "todoText CONTAINS[cd] %@", searchBar.text ?? "")
        request.sortDescriptors = [NSSortDescriptor(key: "todoText", ascending: true)]
        
        loadItems(withRequest: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text ?? "").count == 0{
            loadItems(forCategory: parentCategory!.categoryName!)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

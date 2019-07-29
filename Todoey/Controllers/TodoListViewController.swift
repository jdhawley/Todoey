//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/25/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit

private let dataKey = "TodoItems"

class TodoListViewController: UITableViewController {
    var itemArray = [TodoItem]()
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let items = defaults.array(forKey: dataKey) as? [TodoItem]{
            itemArray = items
        }
        else{
            itemArray.append(TodoItem(todoText: "Find Mike"))
            itemArray.append(TodoItem(todoText: "Buy Eggos"))
            itemArray.append(TodoItem(todoText: "Destroy Demogorgon"))
        }
    }

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
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Todo", message: "Please enter your todo item below.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            guard let todoText = alert.textFields?[0].text
                else{ fatalError("Todo text was unavailable") }
            self.itemArray.append(TodoItem(todoText: todoText))
//            self.defaults.set(self.itemArray, forKey: dataKey)
            self.tableView.reloadData()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField { (textField) in
            textField.placeholder = "Todo Item"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func toggleComplete(indexPath: IndexPath){
        guard let cell = tableView.cellForRow(at: indexPath) else{ fatalError("IndexPath out of range") }
        let todo = itemArray[indexPath.row]
        
        todo.isComplete = !todo.isComplete
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
    }
}

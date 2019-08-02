//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/25/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    
    var todoItems: Results<TodoItem>?
    var parentCategory: Category?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let color = UIColor(hexString: parentCategory!.backgroundColor){
            navigationController?.navigationBar.barTintColor = color
            navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)
            title = parentCategory!.categoryName
            searchBar.barTintColor = color
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true)]
        }
    }

    //MARK: TableView Delegate methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let todo = todoItems?[indexPath.row]{
            cell.textLabel?.text = todo.todoText
            cell.accessoryType = todo.isComplete ? .checkmark : .none
//            cell.backgroundColor = UIColor(hexString: todo.backgroundColor)
            cell.backgroundColor = UIColor(hexString: parentCategory!.backgroundColor)!.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count))
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        }else{
            cell.textLabel?.text = "No items added"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let todo = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    todo.isComplete = !todo.isComplete
                }
            } catch{
                print("Error saving todo done status: \(error)")
            }
        }
        
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
                        item.backgroundColor = UIColor.randomFlat.hexValue()

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
    
    private func loadItems(){
        todoItems = parentCategory?.todoItems.sorted(byKeyPath: "todoText", ascending: true)
        tableView.reloadData()
    }
    
    //MARK: Delete from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let todo = todoItems?[indexPath.row]{
            do{
                try realm.write {
                    realm.delete(todo)
                }
            } catch{
                print("Error deleting category \(todo): \(error)")
            }
        }
    }
}

extension TodoListViewController: UISearchBarDelegate{

    //MARK: SearchBar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("todoText CONTAINS[cd] %@", searchBar.text ?? "").sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text ?? "").count == 0{
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

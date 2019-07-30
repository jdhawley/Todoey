//
//  TodoItem.swift
//  Todoey
//
//  Created by Jonathan Hawley on 7/29/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import Foundation

class TodoItem: Codable{
    var todoText: String
    var isComplete: Bool
    
    init(todoText: String){
        self.todoText = todoText
        self.isComplete = false
    }
    
    init(todoText: String, isComplete: Bool){
        self.todoText = todoText
        self.isComplete = isComplete
    }
}

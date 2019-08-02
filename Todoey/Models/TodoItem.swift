//
//  TodoItem.swift
//  Todoey
//
//  Created by Jonathan Hawley on 8/1/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object{
    @objc dynamic var todoText: String = ""
    @objc dynamic var isComplete: Bool = false
    @objc dynamic var dateCreated: Date? = Date()
    @objc dynamic var backgroundColor: String = "000000"
    let parentCategory = LinkingObjects(fromType: Category.self, property: "todoItems")
}

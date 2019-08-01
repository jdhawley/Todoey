//
//  Category.swift
//  Todoey
//
//  Created by Jonathan Hawley on 8/1/19.
//  Copyright © 2019 Jonathan Hawley. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var categoryName: String = ""
    let todoItems = List<TodoItem>()
}

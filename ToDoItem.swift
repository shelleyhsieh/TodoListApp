//
//  ItemList.swift
//  TodoListApp
//
//  Created by shelley on 2023/2/8.
//

import Foundation
import UIKit


struct ToDoItem: Codable{
    var name: String
    var date: Date
    var note: String
    var reminderSet: Bool
    var notificationID: String
    var complete: Bool
}

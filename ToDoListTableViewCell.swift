//
//  ToDoListTableViewCell.swift
//  TodoListApp
//
//  Created by shelley on 2023/2/8.
//

import UIKit

protocol ToDoListTableViewCellDelegate: class {
    func checkToggle(sender: ToDoListTableViewCell)
}

class ToDoListTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var nameLable: UILabel!
    
    weak var delegate: (ToDoListTableViewCellDelegate)?
    
    var todoList: ToDoItem! {
        didSet {
            nameLable.text = todoList.name
            checkBtn.isSelected = todoList.complete
        }
    }
    
    @IBAction func checkToggled(_ sender: UIButton) {
        delegate?.checkToggle(sender: self)
    }
    
}

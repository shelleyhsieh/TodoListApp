//
//  ToDoDetailTableViewController.swift
//  TodoListApp
//
//  Created by shelley on 2023/2/8.
//

import UIKit

// computy property
private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

class ToDoDetailTableViewController: UITableViewController {

    @IBOutlet weak var saveBarBtn: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicler: UIDatePicker!
    @IBOutlet weak var noteView: UITextView!
    
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var reminderSwitch: UISwitch!
    
    
    // 宣告toDoItem 儲存前一頁傳來的字串
    var toDoItem: ToDoItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if toDoItem == nil {
            toDoItem = ToDoItem(name: "", date: Date().addingTimeInterval(24*60*60), note: "", reminderSet: false, notificationID: "", complete: false)
        }
        
        updateUI()
        
    }
    
    func updateUI () {
        textField.text  = toDoItem.name
        datePicler.date = toDoItem.date
        noteView.text = toDoItem.note
        reminderSwitch.isOn = toDoItem.reminderSet
        dateLable.textColor = (reminderSwitch.isOn ? .black : .gray)
//        if reminderSwitch.isOn {
//            dateLable.textColor = .black
//        } else {
//            dateLable.textColor = .gray
//        }
        dateLable.text = dateFormatter.string(from: toDoItem.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        toDoItem = ToDoItem(name: textField.text!, date: datePicler.date, note: noteView.text, reminderSet: reminderSwitch.isOn, notificationID: "", complete: toDoItem.complete)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func reminderSwitchChanged(_ sender: Any) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    @IBAction func dateFormatterChanged(_ sender: UIDatePicker) {
        dateLable.text = dateFormatter.string(from: sender.date)
    }
}

extension ToDoDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case IndexPath (row: 1, section:1): //date picker
            return reminderSwitch.isOn ? datePicler.frame.height : 0
        case IndexPath (row: 0, section:2):
            return 200
        default:
            return 44
        }
    }
}

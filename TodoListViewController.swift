//
//  TodoListViewController.swift
//  TodoListApp
//
//  Created by shelley on 2023/2/8.
//

import UIKit
import UserNotifications

class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBarBtn: UIBarButtonItem!
    
    var todoList: [ToDoItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self //allow table view send message to viewController
        tableView.dataSource = self //tells to tableView going to get data from viewController
        
        loadData()
        autherizeLocalNotifications()
    }
    
    func autherizeLocalNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard error == nil else {
                print("😡ERROR: \(error!.localizedDescription)")
                return
            }
            if granted {
                print("✅ notifications autherization granted")
            }else {
                print("🚫the user has denied notifications")
                //TODO: put an alert in here telling the user what to do
            }
        }
    }
    
    func setNotifications() {
        guard todoList.count > 0 else { return }
        
        // remove all notification
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // re-create with the update date that we saved
        for index in 0..<todoList.count {
            if todoList[index].reminderSet {
                todoList[index].notificationID = setCalenderNotification(title: todoList[index].name, subtitle: "", body: todoList[index].note, bedgeNumber: nil, sound: .default, date: todoList[index].date)
            }
        }
    }
    
    func setCalenderNotification(title: String, subtitle: String, body: String, bedgeNumber:NSNumber?, sound: UNNotificationSound, date: Date) -> String {
        // Create content
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = bedgeNumber
        
        // create trigger
        var dateComponent = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        dateComponent.second = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        // create request
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // register request in notificaton center
        UNUserNotificationCenter.current().add((request)) { (error) in
            if let error = error {
                print("😡error\(error.localizedDescription)")
            } else {
                print("notification schelduled \(notificationID), title:\(content.title)")
            }
        }
        return notificationID
    }
    
    func loadData() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: documentURL) else {return}
        let jsonDecoder = JSONDecoder()
        do {
            todoList = try jsonDecoder.decode([ToDoItem].self, from: data)
            tableView.reloadData()
        } catch  {
            print("ERROR \(error.localizedDescription)")
        }
        
    }

    func saveDate() {
        let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let documentURL = directoryURL.appendingPathComponent("todos").appendingPathExtension("json")
        
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(todoList)
        do {
            try data?.write(to: documentURL, options: .noFileProtection)
        } catch  {
            print("🥲 \(error.localizedDescription)")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let destination = segue.destination as! ToDoDetailTableViewController
            let seletedIndexPath = tableView.indexPathForSelectedRow!
            destination.toDoItem = todoList[seletedIndexPath.row]  //data being pass
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deleteRows(at: [selectedIndexPath], with: .automatic)
            }
        }
    }
    
    @IBAction  func unwindForDetail(segue: UIStoryboardSegue) {
        let source = segue.source as! ToDoDetailTableViewController
        if let seletedIndexPath = tableView.indexPathForSelectedRow {
            todoList[seletedIndexPath.row] = source.toDoItem
            tableView.reloadRows(at: [seletedIndexPath], with: .automatic)  //data being pass
        } else {
            let newIndexPath = IndexPath(row: todoList.count, section: 0)
            todoList.append(source.toDoItem)  //data being pass
            tableView.insertRows(at: [newIndexPath], with: .bottom)
            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
        }
        saveDate()
    }

    
    
    @IBAction func editBarBtnPressed(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            sender.title = "Edit"
            addBarBtn.isEnabled = true
            
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            addBarBtn.isEnabled = false
        }
    }
    
}

// MARK: - Table View Protocols
extension TodoListViewController: UITableViewDelegate, UITableViewDataSource, ToDoListTableViewCellDelegate {
    
    func checkToggle(sender: ToDoListTableViewCell) {
        if let seletedIndexPath = tableView.indexPath(for: sender){
            todoList[seletedIndexPath.row].complete = !todoList[seletedIndexPath.row].complete
            tableView.reloadRows(at: [seletedIndexPath], with: .automatic)
            saveDate()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath) as! ToDoListTableViewCell
        cell.delegate = self
        cell.nameLable.text =  todoList[indexPath.row].name  //indexpath.row is array element number
        cell.checkBtn.isSelected = todoList[indexPath.row].complete
    
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            todoList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade) //swipe left
            saveDate()
        }
        
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = todoList[sourceIndexPath.row]  //move from source
        todoList.remove(at: sourceIndexPath.row)
        todoList.insert(itemToMove, at: destinationIndexPath.row) //move to destination
        saveDate()
    }
    
    
}

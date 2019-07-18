//
//  ViewController.swift
//  To-Do Manager
//
//  Created by burak kaya on 16/07/2019.
//  Copyright © 2019 burak kaya. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    let colours = ["black","darkGray","lightGray","white","gray","red","green","blue","cyan","yellow","magenta","orange","purple","brown"]
    var colourPicker = UIPickerView()
    var datePicker = UIDatePicker()
    var switchOnOff = UISwitch()
    let toolBarColour = UIToolbar()
    let toolBarDate = UIToolbar()
    var tasks = [Task]()
    let titleTextField = UITextField()
    let categoryTextField = UITextField()
    let dateTextField = UITextField()
    let colourTextField = UITextField()
    var alert = UIAlertController()
    var selectedColour : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
            let notifications = try TaskService.context.fetch(fetchRequest)
            if notifications.count == 0 {
                let notification = Notification(context: TaskService.context)
                notification.isOn = true
                TaskService.saveContext()
            }
        }catch{
            print(error)
        }
        
        self.tableView.rowHeight = 100.0
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do{
            let tasks = try TaskService.context.fetch(fetchRequest)
            self.tasks = tasks
            self.tableView.reloadData()
        }catch{
            print(error)
        }
        
        colourPicker.showsSelectionIndicator = true
        colourPicker.delegate = self
        colourPicker.dataSource = self
        
        toolBarColour.barStyle = UIBarStyle.default
        toolBarColour.isTranslucent = true
        toolBarColour.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBarColour.sizeToFit()
        
        toolBarDate.barStyle = UIBarStyle.default
        toolBarDate.isTranslucent = true
        toolBarDate.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBarDate.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.selectColour))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.cancelButton))
        
        toolBarColour.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBarColour.isUserInteractionEnabled = true
        
        datePicker.datePickerMode = .date
        let doneDateButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.selectDate))
        let spaceDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelDateButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.cancelButton))
        
        toolBarDate.setItems([cancelDateButton, spaceDoneButton, doneDateButton], animated: false)
        toolBarDate.isUserInteractionEnabled = true
    }

    @IBAction func settings(_ sender: Any) {
        let alertController = UIAlertController(title: "Local Notifications Status", message: "\n\n", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)

        alertController.preferredContentSize.height = 300
        alertController.view.addSubview(createSwitch())
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addTask(_ sender: Any) {
        showAlert(type: "add", id: nil)
    }
    
    func createSwitch () -> UISwitch{
        switchOnOff = UISwitch(frame:CGRect(x: 110, y: 50, width: 0, height: 0))
        switchOnOff.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        do{
            let notifications = try TaskService.context.fetch(fetchRequest)
            if notifications.count > 0 {
                switchOnOff.setOn(notifications[0].isOn, animated: false)
            }
        }catch{
            print(error)
        }
        
        return switchOnOff
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch){
        do{
            let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
            let notifications = try TaskService.context.fetch(fetchRequest)
            if (sender.isOn == true){
                if notifications.count > 0 {
                    notifications[0].setValue(true, forKey: "isOn")
                    turnOnNotifications()
                }}
            else{
                if notifications.count > 0 {
                    notifications[0].setValue(false, forKey: "isOn")
                    turnOffNotifications()
                }
            }
            TaskService.saveContext()
        }catch{
            print(error)
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return colours.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return colours[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedColour = colours[row]
    }

    func showAlert(type: String, id: NSManagedObjectID?){
        var titleText = String()
        var dateText : String?
        var categoryText = String()
        var colourText = String()
        
        if type == "add"{
            alert = UIAlertController(title: "ADD TASK", message: "Please, fill the fields!", preferredStyle: UIAlertController.Style.alert)
            
            let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                let title = self.alert.textFields![0] as UITextField
                let category = self.alert.textFields![1] as UITextField
                let date = self.alert.textFields![2] as UITextField
                let colour = self.alert.textFields![3] as UITextField
                
                if title.text == "" || category.text == "" || colour.text == ""{
                    let error = UIAlertController(title: "Alert", message: "Please, fill title, category and colour!", preferredStyle: UIAlertController.Style.alert)
                    error.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                    self.present(error, animated: true, completion: nil)
                }else{
                    if self.colours.contains(colour.text ?? ""){
                        let task = Task(context: TaskService.context)
                        task.title = title.text
                        task.date = date.text
                        task.category = category.text
                        task.colour = colour.text
                        TaskService.saveContext()
                        self.tasks.append(task)
                        self.tableView.reloadData()
                    }else{
                        let error = UIAlertController(title: "Alert", message: "Please, select proper colour!", preferredStyle: UIAlertController.Style.alert)
                        error.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(error, animated: true, completion: nil)
                    }
                }
            }
            alert.addAction(save)
        }else if type == "edit"{
            alert = UIAlertController(title: "EDIT TASK", message: "Please, fill the fields!", preferredStyle: UIAlertController.Style.alert)
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            do{
                let taskss = try TaskService.context.fetch(fetchRequest)
                
                let theTask = taskss.first(where: {$0.objectID == id})
                titleText = (theTask?.title!)!
                dateText = theTask?.date
                categoryText = (theTask?.category!)!
                colourText = (theTask?.colour!)!
                
                let delete = UIAlertAction(title: "Delete", style: .destructive) { (alertaction) in
                    TaskService.context.delete(theTask!)
                    self.tasks = self.tasks.filter{$0 != theTask}
                    self.tableView.reloadData()
                }
                alert.addAction(delete)
                let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
                    let title = self.alert.textFields![0] as UITextField
                    let category = self.alert.textFields![1] as UITextField
                    let date = self.alert.textFields![2] as UITextField
                    let colour = self.alert.textFields![3] as UITextField
                    
                    if title.text == "" || category.text == "" || colour.text == ""{
                        let error = UIAlertController(title: "Alert", message: "Please, fill title, category and colour!", preferredStyle: UIAlertController.Style.alert)
                        error.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                        self.present(error, animated: true, completion: nil)
                    }else{
                        if self.colours.contains(colour.text ?? ""){
                            theTask!.setValue(title.text, forKey: "title")
                            theTask!.setValue(category.text, forKey: "category")
                            theTask!.setValue(colour.text, forKey: "colour")
                            theTask!.setValue(date.text, forKey: "date")
                            
                            TaskService.saveContext()
                            
                            
                            self.tasks.first(where: {$0.objectID == id})!.title = title.text
                            self.tasks.first(where: {$0.objectID == id})!.category = category.text
                            self.tasks.first(where: {$0.objectID == id})!.date = date.text
                            self.tasks.first(where: {$0.objectID == id})!.colour = colour.text
                            
                            self.tableView.reloadData()
                        }else{
                            let error = UIAlertController(title: "Alert", message: "Please, select proper colour!", preferredStyle: UIAlertController.Style.alert)
                            error.addAction(UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: nil))
                            self.present(error, animated: true, completion: nil)
                        }
                    }
                }
                alert.addAction(save)
            }catch{
                print(error)
            }
        }
        
        alert.addTextField { (titleTextField) in
            titleTextField.text = titleText
            titleTextField.placeholder = "Enter the title"
        }
        
        alert.addTextField { (categoryTextField) in
            categoryTextField.text = categoryText
            categoryTextField.placeholder = "Enter the category"
        }
        
        alert.addTextField { (dateTextField) in
            dateTextField.text = dateText
            dateTextField.placeholder = "Enter the date"
            dateTextField.delegate = self
            dateTextField.accessibilityHint = "date"
        }
        
        alert.addTextField { (colourTextField) in
            colourTextField.text = colourText
            colourTextField.placeholder = "Enter the colour"
            colourTextField.delegate = self
            colourTextField.accessibilityHint = "colour"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        
        self.present(alert, animated:true, completion: nil)
    }

    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField.accessibilityHint == "colour"{
            showColours()
        }else if textField.accessibilityHint == "date"{
            showDates()
        }
    }
    
    @objc func showDates(){
        alert.textFields![2].inputView = self.datePicker
        alert.textFields![2].inputAccessoryView = self.toolBarDate
        alert.reloadInputViews()
    }
    
    @objc func selectDate(){
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        alert.textFields![2].text = formatter.string(from: datePicker.date)
        alert.reloadInputViews()
    }
    
    @objc func selectColour(){
        alert.textFields![3].text = selectedColour
        alert.textFields![3].inputView = nil
        alert.textFields![3].inputAccessoryView = nil
        alert.textFields![3].reloadInputViews()
        alert.reloadInputViews()
    }
    
    @objc func showColours(){
        alert.textFields![3].inputView = self.colourPicker
        alert.textFields![3].inputAccessoryView = self.toolBarColour
        alert.reloadInputViews()
    }
    
    
    @objc func cancelButton(){
        alert.textFields![3].inputView = nil
        alert.textFields![3].inputAccessoryView = nil
        alert.textFields![3].reloadInputViews()
        alert.reloadInputViews()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objectID = tasks[indexPath.row].objectID
        showAlert(type: "edit", id: objectID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        cell.selectionStyle = .none
        cell.title.text = tasks[indexPath.row].title
        cell.category.text = tasks[indexPath.row].category
        cell.date.text = tasks[indexPath.row].date
        
        
        if tasks[indexPath.row].date != "" || tasks[indexPath.row].date != nil {
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let cellDate = dateFormatter.date(from: tasks[indexPath.row].date!)
            
            if let cellDate = cellDate{
                if date>cellDate{
                    cell.icon.image = UIImage(named: "cross.png")
                }else{
                    cell.icon.image = UIImage(named: "tick.png")
                }
            }
        }

        
        cell.backgroundColor = tasks[indexPath.row].colour?.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            do{
                let tasks = try TaskService.context.fetch(fetchRequest)
                TaskService.context.delete(tasks[indexPath.row])
                TaskService.saveContext()
            }catch{
                print(error)
            }
            tasks.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
 
    func turnOnNotifications(){
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func turnOffNotifications(){
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do{
            let tasks = try TaskService.context.fetch(fetchRequest)
            
            tasks.forEach({
                if $0.date != ""{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let date = dateFormatter.date(from: $0.date!)
                    self.sendNotification(title: $0.title!, category: $0.category!, date: date!)
                }
            })
        }catch{
            print(error)
        }
        
    }
    
    func sendNotification(title:String,category:String, date:Date){
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = category
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
        }
    }
}

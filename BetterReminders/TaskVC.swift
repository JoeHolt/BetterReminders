//
//  TaskTouchVC.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

enum TaskViewType {
    case NotCompleted
    case All
}

class TaskVC: UITableViewController, AddTaskDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    var classes: [JHSchoolClass]!
    var clas: JHSchoolClass!
    var incompletedTasks: [JHTask]!
    var displayType: TaskViewType = .NotCompleted
    var tasks: [JHTask]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = clas.name
        setUp()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "taskCell")
        cell.textLabel?.text = task.name
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .full
        cell.detailTextLabel?.text = outputFormatter.string(from: task.dueDate!)
        if task.completed == true {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = tasks[indexPath.row]
        task.completed = !task.completed
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.none
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        //Delete task from model and UI
        clas.removeTask(at: indexPath.row)
        reloadTasks()
    }
    
    func didAddTask() {
        //Task was added
        reloadTasks()
    }
    
    func reloadTasks() {
        //Reloads and saves tasks
        saveClasses()
        loadTasks()
        tableView.reloadData()
    }
    
    func saveClasses() {
        //Save classes from defaults
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: classes!)
        UserDefaults.standard.set(data, forKey: "classes")
    }
    
    func addTask() {
        //Adds a new task to the given class
        //Add a popover
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "popoverTaskAdd") as! TaskPopoverVC
        vc.delegate = self
        vc.clas = clas
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover
        if let presentationController = nav.popoverPresentationController {
            presentationController.delegate = self
            presentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            presentationController.sourceView = self.view
            let width = self.view.bounds.width - 30
            let height = UIScreen.main.bounds.height - 150
            presentationController.sourceRect = CGRect(x: (self.view.bounds.width - width)/2, y: 0.0, width: width, height: height - 300)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        //Gives the view controller to be displayed in the popover view contorller
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MainTableViewController.dismissView))
        navigationController.topViewController?.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //.none sets the popover style as an actual popover rather than a full screen view
        return UIModalPresentationStyle.none
    }
    
    func dismissView() {
        //dismiss popover
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func navBarLongPress(sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state == UIGestureRecognizerState.began {
            changeDisplayType()
        }
    }
    
    func changeDisplayType() {
        //Changes display type of classes displayed
        if displayType == .NotCompleted {
            displayType = .All
        } else {
            displayType = .NotCompleted
        }
        reloadTasks()
    }
    
    func loadTasks() {
        //Get array of incompleted tasks
        incompletedTasks = [JHTask]()
        for t in clas.tasks {
            if !t.completed {
                incompletedTasks.append(t)
            }
        }
        //Get tasks to be displayed
        if displayType == .NotCompleted {
            tasks = incompletedTasks
        } else {
            tasks = clas.tasks
        }
    }
    
    func setUp() {
        //General UI set up at vc launch
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        navigationItem.rightBarButtonItem = button
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(navBarLongPress(sender:)))
        longPress.delegate = self
        navigationController?.navigationBar.addGestureRecognizer(longPress)
        
        loadTasks()
        
    }

    

}

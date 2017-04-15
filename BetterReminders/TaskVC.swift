//
//  TaskTouchVC.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

extension UITableView {
    
    /**
        Returns an array of UITableView cells in a given section
        - parameter section: Section of cells
        - returns: Array of cells in section, nil if invalid section
    */
    func cellsForSection(section: Int) -> [UITableViewCell]? {
        
        if section > numberOfSections - 1 {
            //Invalid section (out of range)
            return nil
        }
        
        var cells = [UITableViewCell]()
        var row: Int = 0
        while row < numberOfRows(inSection: section) {
            if let cell = cellForRow(at: IndexPath(row: row, section: section)) {
                cells.append(cell)
            }
            row += 1
        }
        
        return cells
    }
    
    
    /**
        Returns an array containing indexPaths of all cells in section
        - parameter section: Section of requested index paths
        - returns: Array of wanted index paths, nil if invalid section
    */
    func indexPathsForSection(section: Int) -> [IndexPath]? {
        if section > numberOfSections - 1 {
            //Invalid section (out of range)
            return nil
        }
        
        var indexPaths = [IndexPath]()
        var row: Int = 0
        while row < numberOfRows(inSection: section) {
            if let _ = cellForRow(at: IndexPath(row: row, section: section)) {
                indexPaths.append(IndexPath(row: row, section: section))
            }
            row += 1
        }
        
        return indexPaths
    }
}

enum TaskViewType: String {
    case NotCompleted = "Not Completed"
    case Completed = "Completed"
    case All = "All"
}

class TaskVC: UITableViewController, AddTaskDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    
    // MARK: - Properties
    
    
    var schedule: JHSchedule!
    var clas: JHSchoolClass!
    var displayTasks: [JHTask]!
    var displayType: TaskViewType = .NotCompleted
    var feedbackGenerator: UISelectionFeedbackGenerator?
    var quickAddTextField: UITextField?
    
    
    // MARK: - View Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = clas.name
        setUp()
        
    }
    
    
    // MARK: - TableView methods

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //  1 - Time left
        //  2 - Tasks
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            // Time remaining
            return 1
        case 1:
            //Tasks
            return displayTasks.count + 1 //THe one extra is the quick add view
        default:
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            //Total time left
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeLeftCell")
            let (hours, minutes) = clas.timeToCompleteTasks()
            cell?.textLabel?.text = "\(hours) \(getUnitsStringForHours(hours: hours)) and \(minutes) \(getUnitsStringForMinutes(minutes: minutes))"
            cell?.selectionStyle = .none
            cell?.isUserInteractionEnabled = false
            return cell!
        } else if indexPath.section == 1 && indexPath.row == displayTasks.count {
            //Quick add view
            let cell = tableView.dequeueReusableCell(withIdentifier: "quickAddCell")
            let textField = cell?.viewWithTag(5) as! UITextField
            textField.delegate = self
            textField.text = ""
            return cell!
        } else {
            //Tasks
            let task = displayTasks[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "taskCell")
            var displayString = ""
            cell.textLabel?.text = task.name
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .full
            if let due = task.dueDate {
                displayString += "\(outputFormatter.string(from: due)) - "
            }
            if let (hours, minutes) = task.timeToComplete() {
                displayString += "\(timeStringFromHoursAndMinutes(hours: hours, minutes: minutes))"
            }
            cell.detailTextLabel?.text = displayString
            if task.completed == true {
                cell.accessoryType = .checkmark
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            //Total time left
            return 44.0 + 15.0    //Where 44 is default
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { _,_ in
                self.deleteTask(at: indexPath)
            })
            let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { _,_ in
                self.editTask(task: self.clas.tasks[indexPath.row])
            })
            editAction.backgroundColor = UIColor.blue
            
            return [deleteAction, editAction]
        } else {
            return []
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 0 && indexPath.row != displayTasks.count {
            let task = displayTasks[indexPath.row]
            task.completed = !task.completed
            let cell = tableView.cellForRow(at: indexPath)
            if cell?.accessoryType == UITableViewCellAccessoryType.none {
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
        updateTimeLeft()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Tasks - \(displayType.rawValue)"
        } else {
            return "Estimated Time Left"
        }
    }
    
    // MARK: - Text (quick add) View functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField.text?.trimmingCharacters(in: .whitespaces) != "" {
            print("test")
            let task = JHTask(name: textField.text!, completed: false, dueDate: nil, estimatedTimeToComplete: nil)
            schedule.classes[0].tasks.append(task)
            reloadTasks()
        }
        return false
    }
    
    
    // MARK: - Task Functions
    
    
    /**
        Removes task
        - parameter indexPath: Index for task to remove
    */
    private func deleteTask(at indexPath: IndexPath) {
        //Delete task from model and UI
        clas.removeTask(at: indexPath.row)
        reloadTasks()
    }
    
    /**
        Reloads data
     */
    internal func didAddTask() {
        reloadTasks()
    }
    
    /**
        Reloads data
     */
    internal func didEditTask() {
        //Task was edited
        reloadTasks()
    }
    
    /**
        Reloads, saves data
     */
    private func reloadTasks() {
        //Reloads and saves tasks
        saveSchedule()
        loadTasks()
        print("Rload")
        UIView.transition(with: tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)

    }
    
    /**
        Save classes to defaults
     */
    private func saveSchedule() {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: schedule!)
        UserDefaults.standard.set(data, forKey: "schedule")
    }
    
    /**
        Displays addTaskPopover in add mode
     */
    @objc private func addTaskButtonTapped() {
        displayTaskPopover()
    }
    
    /**
        Displays addTaskPopover in edit mode
    */
    private func editTask(task: JHTask) {
        //Edit a task
        displayTaskPopover(editing: true, forTask: task)
    }
    
    /**
        Sets tasks depending on if displayMode
     */
    private func loadTasks() {
        
        //Get tasks to be displayed
        switch displayType {
        case .NotCompleted:
            displayTasks = clas.uncompletedTasks()
        case .Completed:
            displayTasks = clas.completedTasks()
        default:
            displayTasks = clas.tasks
        }

    }
    
    
    // MARK: - TaskPopover
    
    
    /**
        Displays a popup for adding/editing
    */
    private func displayTaskPopover(editing: Bool = false, forTask: JHTask? = nil) {
        //Display a popover for editing or creating
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "popoverTaskAdd") as! TaskPopoverVC
        vc.delegate = self
        vc.clas = clas
        vc.forTask = forTask
        vc.forEditing = editing
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover
        if let presentationController = nav.popoverPresentationController {
            presentationController.delegate = self
            presentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            presentationController.sourceView = self.view
            let width = self.view.bounds.width
            let height = UIScreen.main.bounds.height
            presentationController.sourceRect = CGRect(x: (self.view.bounds.width - width)/2, y: 0.0, width: width, height: height - 150)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    internal func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        //Gives the view controller to be displayed in the popover view contorller
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MainTableViewController.dismissClassPopoverView))
        navigationController.topViewController?.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    internal func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //.none sets the popover style as an actual popover rather than a full screen view
        return UIModalPresentationStyle.none
    }
    
    /**
        Hides task popover view
    */
    internal func dismissTaskPopoverView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Functions
    
    
    /**
     Finds units for gives hours
     - parameter hours: Hours to get units for
     - returns: Untits for given hours
     */
    private func getUnitsStringForHours(hours: Int) -> String {
        if hours == 1 {
            return "Hour"
        } else {
            return "Hours"
        }
    }
    
    /**
     Finds units for gives minutes
     - parameter minutes: Minutes to get units for
     - returns: Untits for given minutes
     */
    private func getUnitsStringForMinutes(minutes: Int) -> String {
        if minutes == 1 {
            return "Minute"
        } else {
            return "Minutes"
        }
    }
    
    
    // MARK: - Display type
    
    
    /**
        Changes display mode of tasks
    */
    @objc private func navBarLongPress(sender: UILongPressGestureRecognizer? = nil) {
        feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator?.prepare()
        if sender?.state == UIGestureRecognizerState.began {
            feedbackGenerator?.selectionChanged()
            changeDisplayType()
        }
        if sender?.state == UIGestureRecognizerState.ended {
            feedbackGenerator = nil
        }
    }
    
    /**
        Changes ui display of tasks
    */
    private func changeDisplayType() {
        //Changes display type of classes displayed
        switch displayType {
        case .NotCompleted:
            displayType = .Completed
        case .Completed:
            displayType = .All
        default:
            displayType = .NotCompleted
        }
        print(displayType.rawValue)
        reloadTasks()
    }
    
    /**
        Updates timeLeft ui
    */
    func updateTimeLeft() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    /**
        UI set up
    */
    private func setUp() {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTaskButtonTapped))
        navigationItem.rightBarButtonItem = button
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(navBarLongPress(sender:)))
        longPress.delegate = self
        navigationController?.navigationBar.addGestureRecognizer(longPress)
        
        loadTasks()
        
    }

    

}

// 
//  ViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class MainTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, AddClassDelegate, UIViewControllerPreviewingDelegate, UIGestureRecognizerDelegate {
    
    
    // MARK - Properties
    
    
    internal let defaults = UserDefaults.standard
    internal var schedule: JHSchedule!
    internal var forceLoadData: Bool = false
    internal var notificationsEnabled: Bool!
    private  var center = UNUserNotificationCenter.current()
    private  var myAppDelegate = UIApplication.shared.delegate as! AppDelegate
    private  var feedBackGenerator: UISelectionFeedbackGenerator?
    internal var tasksToAdd: [[String: JHTask]]? {
        didSet {
            loadTasksToAdd()
        }
    }
    
    
    // MARK: - View Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        if self.view.traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self, sourceView: view)
        }
        getData()
        setUp()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpNotifications(forDates: schedule.classEndTimes())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadTasksFromNotification(reload: true)
    }
    
    /**
        Called when function is about to enter forground
    */
    @objc private func willEnterForeground() {
        loadTasksFromNotification(reload: true)
    }
    
    
    // MARK: - TableView methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            //Time Left Cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "timeLeftCell") else {
                print("dequeueresusableCell not found")
                return UITableViewCell()
            }
            
            if let textLabel = cell.textLabel {
                let (hour, minutes) = schedule.totalTimeToComplete()
                textLabel.text = "\(hour) \(getUnitsStringForHours(hours: hour)) and \(minutes) \(getUnitsStringForMinutes(minutes: minutes))"
            }
            
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = false
            return cell
        } else {
            //Class Cells
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ClassCell")
            let c = schedule.classGivenIndexPath(indexPath: indexPath)
            if let textLabel = cell.textLabel {
                textLabel.text = "\(c.name!)"
            }
            if let detailLabel = cell.detailTextLabel {
                let outputFormatter = DateFormatter()
                outputFormatter.timeStyle = .short
                let (hour,minute) = schedule.classGivenIndexPath(indexPath: indexPath).timeToCompleteTasks()
                detailLabel.text = "\(outputFormatter.string(from: c.startDate))-\(outputFormatter.string(from: c.endDate)) - \(timeStringFromHoursAndMinutes(hours: hour, minutes: minute))"
            }
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "classToTask", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return schedule.classesSortedByDay().keys.count + 1  //+1 = timeLeftCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Estimated Time Left"
        } else {
            let days: [String] = Array(schedule.classesSortedByDay().keys).reversed()    //Reversed so "A" day is first
            return "\(days[section - 1]) Day"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let daysKeys: [String] = Array(schedule.classesSortedByDay().keys).reversed()    //Reversed so "A" day is first
            let daysKey: String = daysKeys[section - 1]
            guard let classByDay = schedule.classesSortedByDay()[daysKey] else {
                print("Invalid key for classesByDay")
                return 0
            }
            return classByDay.count
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section != 0 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {_,_ in
                self.deleteClass(class: self.schedule.classGivenIndexPath(indexPath: indexPath))
                tableView.setEditing(false, animated: true)
            })
            let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: {
                _,_ in
                self.displayEditPopup(forClass: self.schedule.classGivenIndexPath(indexPath: indexPath))
                tableView.setEditing(false, animated: true)
            })
            editAction.backgroundColor = UIColor.blue
            let markAllCompletedAction = UITableViewRowAction(style: .normal, title: "MAC", handler: {
                _,_ in
                self.schedule.classGivenIndexPath(indexPath: indexPath).markAllTasksCompleted()
                tableView.setEditing(false, animated: true)
            })
            markAllCompletedAction.backgroundColor = UIColor.green
            return [deleteAction, editAction, markAllCompletedAction]
        } else {
            return []
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44 + 15
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    
    // MARK: - Notifications
    
    
    /**
        Creates a notification to enter homework for given dates
        - parameter forDates: dates for homework notifications to be created on
    */
    private func registerHomeworkNotifications(forDates dates: [Date]) {
        for date in dates {
            let requesetString: String = stringByAppendingDateAndTime(string: "classFinishedRequest", date: date)
            let actionString: String = stringByAppendingDateAndTime(string: "classFinshedAction", date: date)
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            createNotificationWithTextField(title: "Enter assigned homework", body: "class=\"Class\" \nname=\"Name\" \ndueDate=\"04/15/17\" \ntimeToComplete=\"01:15\"", launchDateHour: hour, launchDateMinute: minute, repeats: false, requestId: requesetString, actionId: actionString, textTitle: "Reminder", textButtonTitle: "Save", textPlaceholder: "Enter arguments here", catagotyId: "classFinishedCatagory", center: center)
        }
    }
    
    /**
        If no notificatinos are currently schedueled, schedules more
        - parameter forDates: Dates to be schedueled for
    */
    private func setUpNotifications(forDates dates: [Date]) {
        //Registers notifications if needed
        var currentNotifications: [UNNotificationRequest] = []
        
        center.getPendingNotificationRequests(completionHandler: {
            requests in
            DispatchQueue.main.async {
                currentNotifications = requests
                if self.notificationsEnabled == true {
                    if currentNotifications.count == 0 {
                        self.registerHomeworkNotifications(forDates: dates)
                    }
                }
            }
        })
    }
    
    /**
        Saves tasks that were created from notifications
    */
    private func loadTasksFromNotification(reload: Bool) {
        tasksToAdd = myAppDelegate.tasksToAdd
        if reload {
            reloadTable()
        } else {
            saveSchedule()
        }
        myAppDelegate.tasksToAdd = []
    }
    
    /**
        Adds tasks that were created from taskToAdd property
    */
    private func loadTasksToAdd() {
        if let tasksToAdd = tasksToAdd {
            for group in tasksToAdd {
                for key in group.keys {
                    for clas in schedule.classes {
                        if clas.name == key {
                            guard let task = group[key] else {
                                print("\(#function): Error finding task")
                                return
                            }
                            clas.addTask(task: task)
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - Peek and Pop
    
    
    internal func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Peek and pop - Present a VC preview when force touching it
        if let indexPath = tableView.indexPathForRow(at: location) {
            if indexPath.section == 0 {
                return nil
            }
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
            vc.clas = schedule.classGivenIndexPath(indexPath: indexPath)
            let navVC = UINavigationController(rootViewController: vc)
            navVC.title = "\(vc.clas.name)"
            
            return navVC
            
        }
        return nil
    }
    
    internal func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Peek and pop - Presents the view contorller when popping - hacky implementation
        let navVC = viewControllerToCommit as! UINavigationController
        let vc = navVC.viewControllers[0] as! TaskVC
        let clas = vc.clas
        guard let storyBoard = storyboard else {
            print("\(#function): Error loading storyboard")
            return
        }
        let newVC = storyBoard.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
        newVC.clas = clas
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    
    // MARK: - School Class Modificatoin
    
    
    /**
        Displays the editing popup for a class
        - parameter c: The class to be edited
    */
    private func displayEditPopup(forClass c: JHSchoolClass) {
        //Edit class
        displayClassCreationPopup(editing: true, forClass: c)
    }
    
    /**
        Confirms with user then deletes a class and reflects it in UI
        - parameter c: Class to be deleted
    */
    private func deleteClass(class c: JHSchoolClass) {
        let ac = UIAlertController(title: "Delete Class", message: "Are you sure you would like to delete \(c.name!)? All of the classes tasks will also be deleted.", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete Class", style: .destructive, handler: {
            action in
            //Deletes class at index path and then reloads data
            var i = 0
            for c2 in self.schedule.classes {
                if c.id == c2.id {
                    self.schedule.removeClass(atIndex: i)
                    break
                }
                i += 1
            }
            self.saveSchedule()
            self.reloadTable()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    /**
        Saves, gets most recent data and reloads table view
    */
    internal func reloadTable() {
        //saveSchedule()
        getData()
        tableView.reloadData()
    }
    
    /**
        Displays a popover controller that allows for the adding or editing of classes
        - parameter editing: Bool that shows tells if popover is used editing
        - parameter forClass: Class that will be edited
    */
    private func displayClassCreationPopup(editing: Bool = false, forClass: JHSchoolClass? = nil) {
        //Instantiate and display popup for creating/editing a class
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "popoverClassAdd") as! ClassPopoverVC
        vc.delegate = self
        vc.forEditing = editing
        vc.editClass = forClass
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
    
    /**
        Loads the JHSchedule model from defaults
    */
    private func loadSchedule() {
        //Loads classes from defaults
        let data = defaults.object(forKey: "schedule") as! Data
        schedule = NSKeyedUnarchiver.unarchiveObject(with: data) as? JHSchedule
    }
    
    /**
        Saves the JHSchedule model to defaults
    */
    private func saveSchedule() {
        //Save classes from defaults
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: schedule!)
        defaults.set(data, forKey: "schedule")
    }
    
    
    // MARK: - Popover
    
    
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
     Ran when add button in rightBarButton is clicked - Displays class add popup
     */
    @objc private func addButtonSelected() {
        //Add button selected in nav bar
        displayClassCreationPopup()
    }
    
    /**
        Dismisses popover
    */
    @objc internal func dismissClassPopoverView() {
        //Called from presentationController:controller:viewControllerForAdaptivePresentationStyle
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Data functions
    
    
    /**
        Sets up UI elements of app
    */
    private func setUp() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonSelected))
        
        //Long press nav bar
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(navBarLongPress(sender:)))
        longPress.delegate = self
        navigationController?.navigationBar.addGestureRecognizer(longPress)
        
    }
    
    /**
        Setts up modal elements of app
    */
    internal func getData() {
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        if !launchedBefore || forceLoadData == true {
            print("First Launch")
            defaults.set(true, forKey: "launchedBefore")
            defaults.set(true, forKey: "notificationsEnabled")
            parseScheduleJSON()
            setUpNotifications(forDates: schedule.classEndTimes())
        } else {
            //Not first launch
            loadSchedule()
        }
        schedule.sortClassesByStartTime()
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") as! Bool
        loadTasksFromNotification(reload: false)
    }
    
    /**
        Loads classes from a JSON in app bundle
        - parameter file: Name of sile to be loaded(excluding file type)
        - returns: JSON object
    */
    internal func loadJSON(fromFile file: String) -> JSON? {
        if let path = Bundle.main.path(forResource: file, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    return jsonObj
                } else {
                    print("Couldn't get JSON from file, check to make sure the file is correct")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invlaide file name/path")
        }
        return nil
    }
    
    /**
        Parses a json names Classes.json in the main app bundle
    */
    internal func parseScheduleJSON() {
        //Used for easy adding of classes -- Wont be used in final user version
        if let json = loadJSON(fromFile: "Classes") {
            var classes = [JHSchoolClass]()
            for item in json["Classes"].arrayValue {
                guard let name = item["name"].string else {
                    print("Error Parsing JSON: class name")
                    return
                }
                guard let day = item["day"].string else {
                    print("Error Parsing JSON: day")
                    return
                }
                guard let startTime = item["startTime"].string else {
                    print("Error Parsing JSON: startTime")
                    return
                }
                guard let endTime = item["endTime"].string else {
                    print("Error Parsing JSON: endTime")
                    return
                }
                let startDate: Date = dateFromString(time: startTime)
                let endDate: Date = dateFromString(time: endTime)
                let c = JHSchoolClass(name: name, startDate: startDate, endDate: endDate, day: day)
                classes.append(c)
                schedule = JHSchedule(classes: classes)
                saveSchedule()
            }
        } else {
            print("JSON not parsed properly")
        }
    }

    
    // MARK: - Helper Functions
    
    
    /**
        Creates a string from a given string and an apended date
        - parameter string: String for body
        - parameter date: Date to be added to string
        - returns: String in the format of string.weekday.04:56
    */
    private func stringByAppendingDateAndTime(string: String, date: Date) -> String! {
        //Notificatin ids must be unique so I add the dates and times for id
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let weekDay = Calendar.current.component(.weekday, from: date)
        let timeString = formatter.string(from: date)
        return string + "." + String(weekDay) + "." + timeString
    }
    
    /**
        Finds units for gives hours
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
     - returns: Untits for given minutes
     */
    private func getUnitsStringForMinutes(minutes: Int) -> String {
        if minutes == 1 {
            return "Minute"
        } else {
            return "Minutes"
        }
    }
    
    
    // MARK:- Misc
    

    /**
        Called when popover view finished editing
    */
    internal func didFinishEditing() {
        reloadTable()
    }
    
    /**
        New class added - Reload table
    */
    func didAddNewClass() {
        reloadTable()
    }
    
    /**
        Toggles if notifications are enabled
    */
    @objc private func navBarLongPress(sender: UILongPressGestureRecognizer) {
        feedBackGenerator = UISelectionFeedbackGenerator()
        guard let generator = feedBackGenerator else {
            print("\(#function): Error creating feedback generator")
            return
        }
        generator.prepare()
        if sender.state == .began {
            generator.selectionChanged()
            notificationsEnabled = !notificationsEnabled
            var message = ""
            if notificationsEnabled == true {
                message = "Enabled"
                setUpNotifications(forDates: schedule.classEndTimes())
            } else {
                center.removeAllPendingNotificationRequests()
                message = "Disabled"
            }
            defaults.set(notificationsEnabled, forKey: "notificationsEnabled")
            let ac = UIAlertController(title: "Notifications \(message)", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: { _ in })
            ac.addAction(action)
            present(ac, animated: true, completion: nil)
        }
        if sender.state == UIGestureRecognizerState.ended {
            feedBackGenerator = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! TaskVC
        let indexPath = tableView.indexPathForSelectedRow
        nextVC.clas = schedule.classGivenIndexPath(indexPath: indexPath!)
        nextVC.schedule = schedule
    }
    
}


//
//  ViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate, AddClassDelegate, UIViewControllerPreviewingDelegate {
    
    let defaults = UserDefaults.standard
    var classes: [JHSchoolClass]?
    var classesByDay: [String: [JHSchoolClass]]!
    var forceLoadData: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        
        getData()
        setUp()

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ClassCell")
        let c = classGivenIndexPath(indexPath: indexPath)
        cell.textLabel?.text = "\(c.name!)"
        let outputFormatter = DateFormatter()
        outputFormatter.timeStyle = .short
        cell.detailTextLabel?.text = "\(outputFormatter.string(from: c.startDate))-\(outputFormatter.string(from: c.endDate))"
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "classToTask", sender: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return classesByDay.keys.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let days: [String] = Array(classesByDay.keys).reversed()    //Reversed so "A" day is first
        return "\(days[section]) Day"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let days: [String] = Array(classesByDay.keys).reversed()    //Reversed so "A" day is first
        return classesByDay[days[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: "Delete Class", message: "Are you sure you would like to delete this class? All of the classes tasks will also be deleted.", preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Delete Class", style: .destructive, handler: {
                action in
                //Deletes class at index path and then reloads data
                //Finds the class in classesByDay structure then deletes in from classes array, could be redone for betterr reading and efficency
                let clas = self.classGivenIndexPath(indexPath: indexPath)
                var i = 0
                for c in self.classes! {
                    if c == clas {
                        self.classes?.remove(at: i)
                        break
                    }
                    i += 1
                }
                self.refreshData()
                self.tableView.reloadData()
            }))
            ac.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
        }
    }

    
    func didAddNewClass() {
        //New class added from popover view controller
        getData()
        tableView.reloadData()
    }
    
    func didCancelAddNewClass() {
        //Cancled creation of new class from popover view contorller
    }
    
    func setUp() {
        //General code to set up app when launched
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonSelected))
        
        //Register view for 3D touch preview
        registerForPreviewing(with: self, sourceView: view)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Peek and pop - Present a VC preview when force touching it
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
            vc.clas = classGivenIndexPath(indexPath: indexPath)
            let navVC = UINavigationController(rootViewController: vc)
            navVC.title = "\(vc.clas.name)"
            
            return navVC
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // Peek and pop - Presents the view contorller when popping - hacky implementation
        let navVC = viewControllerToCommit as! UINavigationController
        let vc = navVC.viewControllers[0] as! TaskVC
        let clas = vc.clas
        let newVC = storyboard?.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
        newVC.clas = clas
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func addButtonSelected() {
        //Creates and presents a popover view controller for adding a new class
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "popoverAdd") as! AddPopoverVC
        vc.delegate = self
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
    
    func dismissView() {
        //Called from presentationController:controller:viewControllerForAdaptivePresentationStyle
        self.dismiss(animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //.none sets the popover style as an actual popover rather than a full screen view
        return UIModalPresentationStyle.none
    }
    
    func getData() {
        //Gets data, either from JSON or NSUserDefaults depending on launch
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        if !launchedBefore || forceLoadData == true {
            //First Launch
            defaults.set(true, forKey: "launchedBefore")
            parseScheduleJSON()
        } else {
            //Not first launch
            let data = defaults.object(forKey: "classes") as! Data
            classes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [JHSchoolClass]
        }
        classes = sortClassesByStartTime(classes: classes!)
        classesByDay = sortClassesByDay(classes: classes!)
        classes?[0].tasks = [JHTask(name: "HW", completed: false, dueDate: "1/1/2018", estimatedTimeToComplete: "1:44")]
    }
    
    func refreshData() {
        //Refreshs classes
        classes = sortClassesByStartTime(classes: classes!)
        classesByDay = sortClassesByDay(classes: classes!)
    }
    
    func loadJSON(fromFile file: String, ofType type: String) -> JSON? {
        //Loads the school scheduele JSON containing class info from the main bundle
        if let path = Bundle.main.path(forResource: file, ofType: type) {
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
    
    func parseScheduleJSON() {
        //Parses JSON of school classes in the app bundle
        //Used for easy adding of classes -- Wont be used in final user version
        if let json = loadJSON(fromFile: "Classes", ofType: "json") {
            classes = [JHSchoolClass]()
            for item in json["Classes"].arrayValue {
                if let name = item["name"].string {
                    if let day = item["day"].string {
                        if let startTime = item["startTime"].string {
                            if let endTime = item["endTime"].string {
                                let startDate: Date = dateFromString(time: startTime)
                                let endDate: Date = dateFromString(time: endTime)
                                let c = JHSchoolClass(name: name, startDate: startDate, endDate: endDate, day: day)
                                classes!.append(c)
                                let data: Data = NSKeyedArchiver.archivedData(withRootObject: classes!)
                                defaults.set(data, forKey: "classes")
                            } else {
                                print("Error parsing JSON")
                            }
                        } else {
                            print("Error parsing JSON")
                        }
                    } else {
                        print("Error parsing JSON")
                    }
                } else {
                    print("Error parsing JSON")
                }
            }
        } else {
            print("JSON not parsed properly")
        }
    }
    
    func sortClassesByDay(classes: [JHSchoolClass]) -> [String: [JHSchoolClass]] {
        //Organizes classes into which class scheduele day in order for tableView organization
        classesByDay = [String: [JHSchoolClass]]()
        for c in classes {
            if classesByDay[c.day] == nil {
                classesByDay[c.day] = [c]
            } else {
                classesByDay[c.day]?.append(c)
            }
        }
        return classesByDay
    }
    
    func sortClassesByStartTime(classes: [JHSchoolClass]) -> [JHSchoolClass] {
        // Sorts classes by startDate method
        let newClasses = classes.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
        return newClasses
    }
    
    func classGivenIndexPath(indexPath: IndexPath) -> JHSchoolClass {
        //Hacky method to return the class of a given indexPath on the table view from classesByDay
        let day = dayGivenIndexPath(indexPath: indexPath)
        let clas = classesByDay[day]?[(indexPath.row)]
        return clas!
    }
    
    func dayGivenIndexPath(indexPath: IndexPath) -> String {
        return Array(classesByDay.keys).reversed()[(indexPath.section)] as String
    }
    
    func indexForIndexPathWithManySections(indexPath: IndexPath) -> Int {
        //Returns the "cell number" for a cell with multiple sections
        //ie: cell with section 0 containing 3 cells and section 1 containing 2 cells, this func
        //would return 5 for the index path of the second cell in section 1.(3 cells in 0 + 2 in 1)
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            return row
        } else {
            var index = row
            for x in 0...section-1 {
                index += tableView.numberOfRows(inSection: x)
            }
            return index
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! TaskVC
        let indexPath = tableView.indexPathForSelectedRow
        nextVC.clas = classGivenIndexPath(indexPath: indexPath!)
    }
    
    
}


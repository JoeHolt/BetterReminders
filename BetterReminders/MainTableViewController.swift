//
//  ViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
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
        let index = indexForIndexPathWithManySections(indexPath: indexPath)
        let c = classes![index]
        cell.textLabel?.text = "\(c.name!)"
        cell.detailTextLabel?.text = "\(c.startTime!)-\(c.endTime!)"
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
    
    
    func loadJSON(fromFile file: String, ofType type: String) -> JSON? {
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
    
    func setUp() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonSelected))
    }
    
    func addButtonSelected() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "popoverAdd")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover
        if let presentationController = nav.popoverPresentationController {
            presentationController.delegate = self
            presentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            presentationController.sourceView = self.view
            let width = self.view.bounds.width - 76
            let height = UIScreen.main.bounds.height - 150
            presentationController.sourceRect = CGRect(x: (self.view.bounds.width - width)/2, y: 0.0, width: width, height: height)
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        let navigationController = UINavigationController(rootViewController: controller.presentedViewController)
        let btnDone = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(MainTableViewController.dismissView))
        navigationController.topViewController?.navigationItem.rightBarButtonItem = btnDone
        return navigationController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getData() {
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
        sortClassesByDay()
        classes?[0].tasks = [JHTask(name: "HW", completed: false, dueDate: "1/1/2018", estimatedTimeToComplete: "1:44")]
    }
    
    func parseScheduleJSON() {
        if let json = loadJSON(fromFile: "Classes", ofType: "json") {
            classes = [JHSchoolClass]()
            for item in json["Classes"].arrayValue {
                if let name = item["name"].string {
                    if let day = item["day"].string {
                        if let startTime = item["startTime"].string {
                            if let endTime = item["endTime"].string {
                                let c = JHSchoolClass(name: name, startTime: startTime, endTime: endTime, day: day)
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
    
    func sortClassesByDay() {
        //Organizes classes into which class scheduele day in order for tableView organization
        classesByDay = [String: [JHSchoolClass]]()
        for c in classes! {
            if classesByDay[c.day] == nil {
                classesByDay[c.day] = [c]
            } else {
                classesByDay[c.day]?.append(c)
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! TaskVC
        let indexPath = tableView.indexPathForSelectedRow
        let index = indexForIndexPathWithManySections(indexPath: indexPath!)
        nextVC.clas = classes?[index]
    }
    
    func indexForIndexPathWithManySections(indexPath: IndexPath) -> Int {
        
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
    
    
    
}


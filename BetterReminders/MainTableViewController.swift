//
//  ViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {
    
    let defaults = UserDefaults.standard
    var classes: [JHSchoolClass]?
    var classesByDay: [String: [JHSchoolClass]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Schedule"
        
        getData()

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
    
    func getData() {
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        if !launchedBefore {
            //First Launch
            defaults.set(true, forKey: "launchedBefore")
            parseScheduleJSON()
        } else {
            //Not first launch
            let data = defaults.object(forKey: "classes") as! Data
            classes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [JHSchoolClass]
        }
        sortClassesByDay()
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
        let nextVC = segue.destination as! TaskTouchVC
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


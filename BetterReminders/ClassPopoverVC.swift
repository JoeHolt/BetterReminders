//
//  AddPopoverVCViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/31/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

@objc protocol AddClassDelegate {
    func didAddNewClass()
    func didFinishEditing()
}

class ClassPopoverVC: UITableViewController {

    @IBOutlet weak var classNameTF: UITextField!
    @IBOutlet weak var dayTF: UITextField!
    @IBOutlet weak var startPicker: UIDatePicker!
    @IBOutlet weak var endPicker: UIDatePicker!
    
    
    internal var delegate: AddClassDelegate?
    internal var forEditing: Bool!
    internal var editClass: JHSchoolClass?
    private  var schedule: JHSchedule!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
    }
    
    /**
        UI Set up
     */
    private func setUp() {
        //Basic ui setup
        title = "Add Class"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        //Load classes
        let data = UserDefaults.standard.object(forKey: "schedule") as! Data
        schedule = NSKeyedUnarchiver.unarchiveObject(with: data) as? JHSchedule
        
        //Set up based on if editing
        if forEditing == true {
            if let c = editClass {
                classNameTF.placeholder = c.name
                classNameTF.text = c.name
                dayTF.placeholder = c.day
                dayTF.text = c.day
                startPicker.date = c.startDate
                endPicker.date = c.endDate
            } else {
                print("Error editing class")
            }
        }
    }
    
    /**
        Saves new class/edited class from popover
     */
    @objc private func save() {
        //Saves a new class from provided information in popover
    
        //Get data from view
        let name: String!
        let day: String!
        let startTime: Date!
        let endTime: Date!
        if !(classNameTF.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            name = classNameTF.text
        } else {
            name = "Untitled"
        }
        if !(dayTF.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            day = dayTF.text
        } else {
            day = "A"
        }
        startTime = startPicker.date
        endTime = startPicker.date
        let newClass = JHSchoolClass(name: name, startDate: startTime, endDate: endTime, day: day)
        if !forEditing {
            schedule.classes.append(newClass)
        } else {
            //Take edited class and replace old, nonedited class with ti
            if let editClassInitial = editClass {
                var i = 0
                for c in schedule.classes {
                    if editClassInitial.id == c.id {
                        schedule.classes[i] = newClass
                    }
                    i += 1
                }
            }
        }
        //Save classes with new/edited class
        let data = NSKeyedArchiver.archivedData(withRootObject: schedule)
        UserDefaults.standard.set(data, forKey: "schedule")
        if forEditing == false {
            delegate?.didAddNewClass()
        } else {
            delegate?.didFinishEditing()
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
        Dismiss popover
     */
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }

}

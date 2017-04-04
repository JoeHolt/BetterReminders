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
    func didCancelAddNewClass()
    func didFinishEditing()
}

class ClassPopoverVC: UITableViewController {

    @IBOutlet weak var classNameTF: UITextField!
    @IBOutlet weak var dayTF: UITextField!
    @IBOutlet weak var startTF: UITextField!
    @IBOutlet weak var endTF: UITextField!
    
    var delegate: AddClassDelegate?
    var forEditing: Bool!
    var editClass: JHSchoolClass?
    var classes: [JHSchoolClass]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
        
    }
    
    func setUp() {
        //Basic ui setup
        title = "Add Class"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        //Load classes
        let data = UserDefaults.standard.object(forKey: "classes") as! Data
        classes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [JHSchoolClass]
        
        //Set up based on if editing
        if forEditing == true {
            if let c = editClass {
                classNameTF.placeholder = c.name
                classNameTF.text = c.name
                dayTF.placeholder = c.day
                dayTF.text = c.day
                let outputter = DateFormatter()
                outputter.timeStyle = .short
                startTF.placeholder = outputter.string(from: c.startDate)
                startTF.text = outputter.string(from: c.startDate)
                endTF.placeholder = outputter.string(from: c.endDate)
                endTF.text = outputter.string(from: c.endDate)
            } else {
                print("Error editing class")
            }
        }
    }
    
    func save() {
        //Saves a new class from provided information in popover
    
        //Get data from view
        let name: String!
        let day: String!
        let startTime: String!
        let endTime: String!
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
        if !(startTF.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            startTime = startTF.text
        } else {
            startTime = "07:55 AM"
        }
        if !(endTF.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            endTime = endTF.text
        } else {
            endTime = "08:55 AM"
        }
        let newClass = JHSchoolClass(name: name, startDate: dateFromString(time: startTime), endDate: dateFromString(time: endTime), day: day)
        if !forEditing {
            //Create a new class
            classes?.append(newClass)
        } else {
            //Take edited class and replace old, nonedited class with ti
            if let editClassInitial = editClass {
                var i = 0
                for c in classes {
                    if editClassInitial.id == c.id {
                        classes[i] = newClass
                    }
                    i += 1
                }
            }
        }
        //Save classes with new/edited class
        let data = NSKeyedArchiver.archivedData(withRootObject: classes!)
        UserDefaults.standard.set(data, forKey: "classes")
        if forEditing == false {
            delegate?.didAddNewClass()
        } else {
            delegate?.didFinishEditing()
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func cancel() {
        delegate?.didCancelAddNewClass()
        dismiss(animated: true, completion: nil)
    }

}

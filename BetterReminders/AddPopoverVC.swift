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
}

class AddPopoverVC: UITableViewController {

    @IBOutlet weak var classNameTF: UITextField!
    @IBOutlet weak var dayTF: UITextField!
    @IBOutlet weak var startTF: UITextField!
    @IBOutlet weak var endTF: UITextField!
    
    var delegate: AddClassDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Class"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        
    }
    
    func save() {
        //Saves a new class from provided information in popover
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
            startTime = "7:55"
        }
        if !(endTF.text?.trimmingCharacters(in: .whitespaces).isEmpty)! {
            endTime = endTF.text
        } else {
            endTime = "8:55"
        }
        let newClass = JHSchoolClass(name: name, startDate: dateFromString(time: startTime), endDate: dateFromString(time: endTime), day: day)
        var data = UserDefaults.standard.object(forKey: "classes") as! Data
        var classes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [JHSchoolClass]
        classes?.append(newClass)
        data = NSKeyedArchiver.archivedData(withRootObject: classes!)
        UserDefaults.standard.set(data, forKey: "classes")
        delegate?.didAddNewClass()
        dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        delegate?.didCancelAddNewClass()
        dismiss(animated: true, completion: nil)
    }

}

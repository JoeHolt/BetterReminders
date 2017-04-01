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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancle", style: .plain, target: self, action: #selector(cancle))
        
        
    }
    
    func save() {
        let name: String!
        let day: String!
        let startTime: String!
        let endTime: String!
        if let newName = classNameTF.text {
            name = newName
        } else {
            name = "Untitled"
        }
        if let newDay = dayTF.text {
            day = newDay
        } else {
            day = "A"
        }
        if let newStartTime = startTF.text {
            startTime = newStartTime
        } else {
            startTime = "7:55"
        }
        if let newEndTime = endTF.text {
            endTime = newEndTime
        } else {
            endTime = "8:55"
        }
        let newClass = JHSchoolClass(name: name, startTime: startTime, endTime: endTime, day: day)
        var data = UserDefaults.standard.object(forKey: "classes") as! Data
        var classes = NSKeyedUnarchiver.unarchiveObject(with: data) as? [JHSchoolClass]
        classes?.append(newClass)
        data = NSKeyedArchiver.archivedData(withRootObject: classes!)
        //UserDefaults.standard.set(data, forKey: "classes")
        delegate?.didAddNewClass()
    }
    
    func cancle() {
        delegate?.didCancelAddNewClass()
        dismiss(animated: true, completion: nil)
    }

}

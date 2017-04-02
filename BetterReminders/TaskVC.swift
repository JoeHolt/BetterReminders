//
//  TaskTouchVC.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class TaskVC: UITableViewController {
    
    var clas: JHSchoolClass!
    
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
        return clas.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "taskCell")
        cell.textLabel?.text = clas.tasks[indexPath.row].name
        cell.detailTextLabel?.text = "\(clas.tasks[indexPath.row].dueDate!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func addTask() {
        //Adds a new task to the given class
        //Add a popover
    }
    
    func setUp() {
        //General UI set up at vc launch
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        
    }

    

}

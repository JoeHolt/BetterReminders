//
//  AddPopoverVCViewController.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/31/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class AddPopoverVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Class"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "popCell")
        cell.backgroundColor = UIColor.red
        cell.textLabel?.text = "First"
        return cell
    }

}

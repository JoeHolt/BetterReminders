//
//  JHTask.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class JHTask: NSCoder {
    
    var name: String!
    var completed: Bool!
    var dueDate: String!
    var timeToComplete: String!
    
    init(name: String, completed: Bool, dueDate: String, timeToComplete: String) {
        self.name = name
        self.completed = completed
        self.dueDate = dueDate
        self.timeToComplete = timeToComplete
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.completed = decoder.decodeBool(forKey: "completed")
        self.dueDate = decoder.decodeObject(forKey: "dueDate") as! String
        self.timeToComplete = decoder.decodeObject(forKey: "timeToCopmlete") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(completed, forKey: "completed")
        coder.encode(dueDate, forKey: "dueDate")
        coder.encode(timeToComplete, forKey: "timeToComplete")
    }
    
    
    
}

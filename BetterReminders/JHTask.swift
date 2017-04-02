//
//  JHTask.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

//@objc(JHTask)
class JHTask: NSObject, NSCoding {
    
    //Class reminder
    
    var name: String!
    var completed: Bool!
    var dueDate: String!
    var estimatedTimeToComplete: String!
    
    init(name: String, completed: Bool, dueDate: String, estimatedTimeToComplete: String) {
        self.name = name
        self.completed = completed
        self.dueDate = dueDate
        self.estimatedTimeToComplete = estimatedTimeToComplete
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.completed = decoder.decodeObject(forKey: "completed") as! Bool
        self.dueDate = decoder.decodeObject(forKey: "dueDate") as! String
        self.estimatedTimeToComplete = decoder.decodeObject(forKey: "estimatedTimeToComplete") as! String
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(completed, forKey: "completed")
        coder.encode(dueDate, forKey: "dueDate")
        coder.encode(estimatedTimeToComplete, forKey: "estimatedTimeToComplete")
    }
    
    
    
}

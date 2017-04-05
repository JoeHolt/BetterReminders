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
    
    internal var name: String!
    internal var completed: Bool!
    internal var dueDate: Date!
    internal var estimatedTimeToComplete: Date!
    internal var id: Int!
    
    init(name: String, completed: Bool, dueDate: Date, estimatedTimeToComplete: Date) {
        self.name = name
        self.completed = completed
        self.dueDate = dueDate
        self.estimatedTimeToComplete = estimatedTimeToComplete
        self.id = Int(arc4random_uniform(999999999))
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.completed = decoder.decodeObject(forKey: "completed") as! Bool
        self.dueDate = decoder.decodeObject(forKey: "dueDate") as! Date
        self.estimatedTimeToComplete = decoder.decodeObject(forKey: "estimatedTimeToComplete") as! Date
        self.id = decoder.decodeObject(forKey: "id") as! Int
    }
    
    internal func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(completed, forKey: "completed")
        coder.encode(dueDate, forKey: "dueDate")
        coder.encode(estimatedTimeToComplete, forKey: "estimatedTimeToComplete")
        coder.encode(id, forKey: "id")
    }
    internal func timeToComplete() -> (Int, Int) {
        //Returns time to finish task in (hour, minute) format
        var hours = 0
        var minutes = 0
        
        if completed == false {
            let tComps = Calendar.current.dateComponents(in: .current, from: estimatedTimeToComplete)
            hours += tComps.hour!
            minutes += tComps.minute!
            while minutes >= 60 {
                minutes = minutes - 60
                hours += 1
            }
        }
        return (hours, minutes)
    }
    
}

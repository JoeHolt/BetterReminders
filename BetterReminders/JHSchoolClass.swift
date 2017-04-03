//
//  File.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/27/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import Foundation

@objc(JHSchoolClass)
class JHSchoolClass: NSObject, NSCoding {
    
    // Class
    
    var name: String!
    var startDate: Date!
    var endDate: Date!
    var day: String!
    var tasks: [JHTask] = []
    
    override var description: String {
        return name
    }
    
    init(name: String, startDate: Date, endDate: Date, day: String) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.day = day
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.startDate = decoder.decodeObject(forKey: "startDate") as! Date
        self.endDate = decoder.decodeObject(forKey: "endDate") as! Date
        self.day = decoder.decodeObject(forKey: "day") as! String
        if decoder.decodeObject(forKey: "tasks") as? [JHTask] != nil {
            self.tasks = decoder.decodeObject(forKey: "tasks") as! [JHTask]
        } else {
            self.tasks = []
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(startDate, forKey: "startDate")
        coder.encode(endDate, forKey: "endDate")
        coder.encode(day, forKey: "day")
        coder.encode(tasks, forKey: "tasks")
    }
    
    func addTask(task: JHTask, atStart: Bool = false) {
        if atStart {
            tasks.insert(task, at: 0)
        } else {
            tasks.append(task)
        }
    }
    
    func removeTask(at index: Int) {
        tasks.remove(at: index)
    }
    
    
}

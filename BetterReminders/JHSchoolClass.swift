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


    // MARK: - Properties
    
    
    internal var name: String!
    internal var startDate: Date!
    internal var endDate: Date!
    internal var day: String!
    internal var notifyAtEnd: Bool!
    internal var tasks: [JHTask] = []
    internal var id: Int!
    override var description: String {
        return name
    }
    
    
    // MARK: - Init functions
    
    
    init(name: String, startDate: Date, endDate: Date, day: String, notify: Bool = true) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.day = day
        self.notifyAtEnd = notify
        self.id = Int(arc4random_uniform(999999999))
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.startDate = decoder.decodeObject(forKey: "startDate") as! Date
        self.endDate = decoder.decodeObject(forKey: "endDate") as! Date
        self.day = decoder.decodeObject(forKey: "day") as! String
        self.id = decoder.decodeObject(forKey: "id") as! Int
        self.notifyAtEnd = decoder.decodeObject(forKey: "notifyAtEnd") as! Bool
        if decoder.decodeObject(forKey: "tasks") as? [JHTask] != nil {
            self.tasks = decoder.decodeObject(forKey: "tasks") as! [JHTask]
        } else {
            self.tasks = []
        }
    }
    
    internal func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(startDate, forKey: "startDate")
        coder.encode(endDate, forKey: "endDate")
        coder.encode(day, forKey: "day")
        coder.encode(tasks, forKey: "tasks")
        coder.encode(id, forKey: "id")
        coder.encode(id, forKey: "notifyAtEnd")
    }
    
    
    // MARK: - Time functinos
    
    
    /**
        Finds time to complete class tasks
        - returns: Time to complete in minutes and hours: (hours, minutes)
    */
    internal func timeToCompleteTasks() -> (Int, Int) {
        //Returns time to finish tasks in (hour, minute) format
        var hours = 0
        var minutes = 0
        for t in tasks {
            if t.completed == false {
                let tComps = Calendar.current.dateComponents(in: .current, from: t.estimatedTimeToComplete)
                hours += tComps.hour!
                minutes += tComps.minute!
                while minutes >= 60 {
                    minutes = minutes - 60
                    hours += 1
                }
            }
        }
        return (hours, minutes)
    }
    
    
    // MARK: - Task functinos
    
    
    /**
        Returns array of uncompleted tasks
        - returns: array of uncompleted tasks
    */
    internal func uncompletedTasks() -> [JHTask] {
        var uTasks = [JHTask]()
        for task in tasks {
            if task.completed == false {
                uTasks.append(task)
            }
        }
        return uTasks
    }
    
    /**
     Returns array of completed tasks
     - returns: array of completed tasks
     */
    internal func completedTasks() -> [JHTask] {
        var uTasks = [JHTask]()
        for task in tasks {
            if task.completed == true {
                uTasks.append(task)
            }
        }
        return uTasks
    }
    
    
    /**
        Marks all tasks in class completed
    */
    internal func markAllTasksCompleted() {
        for task in tasks {
            task.completed = true
        }
    }
    
    /**
        Adds new task to class
        - parameter task: Task to be added
        - parameter atStart: Add task at start?
    */
    internal func addTask(task: JHTask, atStart: Bool = false) {
        if atStart {
            tasks.insert(task, at: 0)
        } else {
            tasks.append(task)
        }
    }
    
    /**
        Removes task
        - parameter index: Index of task to be removed
    */
    internal func removeTask(at index: Int) {
        tasks.remove(at: index)
    }
    
    
}

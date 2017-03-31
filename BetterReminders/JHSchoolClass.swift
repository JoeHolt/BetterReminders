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
    var name: String!
    var startTime: String!
    var endTime: String!
    var day: String!
    var tasks: [JHTask] = []
    
    init(name: String, startTime: String, endTime: String, day: String) {
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
        self.day = day
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.startTime = decoder.decodeObject(forKey: "startTime") as! String
        self.endTime = decoder.decodeObject(forKey: "endTime") as! String
        self.day = decoder.decodeObject(forKey: "day") as! String
        if decoder.decodeObject(forKey: "tasks") as? [JHTask] != nil {
            self.tasks = decoder.decodeObject(forKey: "tasks") as! [JHTask]
        } else {
            self.tasks = []
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(startTime, forKey: "startTime")
        coder.encode(endTime, forKey: "endTime")
        coder.encode(day, forKey: "day")
        coder.encode(tasks, forKey: "tasks")
    }
    
    
}

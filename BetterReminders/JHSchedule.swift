//
//  JHSchedule.swift
//  BetterReminders
//
//  Created by Joe Holt on 4/5/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class JHSchedule: NSObject, NSCoding {

    internal var classes: [JHSchoolClass]!
    
    init(classes: [JHSchoolClass]) {
        self.classes = classes
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.classes = aDecoder.decodeObject(forKey: "classes") as! [JHSchoolClass]
    }
    
    internal func encode(with aCoder: NSCoder) {
        aCoder.encode(classes, forKey: "classes")
    }
    
    private func classEndDates() -> [Date] {
        //Returns an array of all the class endtimes as Dates
        var endDates = [Date]()
        for c in classes {
            if !endDates.contains(c.endDate) {
                endDates.append(c.endDate)
            }
            endDates.append(c.endDate)
        }
        return endDates
    }
    
    internal func removeClass(atIndex index: Int) {
        classes.remove(at: index)
    }
    
    internal func classEndTimes() -> [Date] {
        //Returns an array of all class endTimes as dates with only the time
        let endDates = classEndDates()
        var endTimes = [Date]()
        for date in endDates {
            var newComponents = DateComponents()
            let hour = Calendar.current.component(.hour, from: date)
            let minute = Calendar.current.component(.minute, from: date)
            newComponents.hour = hour
            newComponents.minute = minute
            let time = Calendar.current.date(from: newComponents)
            endTimes.append(time!)
        }
        return endTimes
    }
    
    internal func classesSortedByDay() -> [String: [JHSchoolClass]] {
        //Returns classes in a dictinoary of arrays
        var classesByDay = [String: [JHSchoolClass]]()
        for c in classes {
            if classesByDay[c.day] == nil {
                classesByDay[c.day] = [c]
            } else {
                classesByDay[c.day]?.append(c)
            }
        }
        return classesByDay
    }
    
    internal func sortClassesByStartTime() {
        // Sorts classes by startDate property
        classes = classes.sorted(by: { $0.startDate.compare($1.startDate) == .orderedAscending })
    }
    
    internal func classGivenIndexPath(indexPath: IndexPath) -> JHSchoolClass {
        //Hacky method to return the class of a given indexPath on the table view from classesByDay
        let day = dayGivenIndexPath(indexPath: indexPath)
        let clas = classesSortedByDay()[day]?[(indexPath.row)]
        return clas!
    }
    
    private func dayGivenIndexPath(indexPath: IndexPath) -> String {
        //Day given an index path of a class
        return Array(classesSortedByDay().keys).reversed()[(indexPath.section - 1)] as String
    }
    

}

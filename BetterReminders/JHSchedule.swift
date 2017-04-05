//
//  JHSchedule.swift
//  BetterReminders
//
//  Created by Joe Holt on 4/5/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit

class JHSchedule: NSObject, NSCoding {

    var classes: [JHSchoolClass]!
    
    init(classes: [JHSchoolClass]) {
        self.classes = classes
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.classes = aDecoder.decodeObject(forKey: "classes") as! [JHSchoolClass]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(classes)
    }

}

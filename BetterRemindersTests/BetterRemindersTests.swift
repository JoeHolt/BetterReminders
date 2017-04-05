//
//  BetterRemindersTests.swift
//  BetterRemindersTests
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import XCTest
@testable import BetterReminders

class BetterRemindersTests: XCTestCase {
    
    var basicSchoolClass: JHSchoolClass!
    var tableView = MainTableViewController()
    var delegate = AppDelegate()
    
    override func setUp() {
        super.setUp()
        tableView.forceLoadData = true
        basicSchoolClass = JHSchoolClass(name: "Test", startDate: Date(), endDate: Date(), day: "A")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJHSchoolClassInit() {
        XCTAssertTrue(basicSchoolClass.day == "A" || basicSchoolClass.day == "B", "Class initiated with an invalid day")
    }
    
    func testLoadingOfJSON() {
        let data = tableView.loadJSON(fromFile: "TestJSON", ofType: "json")
        XCTAssertTrue(data!["People"].arrayValue.count == 2)
        XCTAssertTrue(data!["People"].arrayValue[0]["name"] == "Joe")
    }
    
    func testParseJSON() {
        tableView.parseScheduleJSON()
        XCTAssertTrue(tableView.schedule.classes.count == 10, "Parsing JSON brought \(tableView.schedule.classes?.count) classes, there should be 10)")
    }
    
    func testClassOrderByTime() {
        let class1 = JHSchoolClass(name: "Test1", startDate: dateFromString(time: "07:55 AM"), endDate: dateFromString(time: "07:55 AM"), day: "A")
        let class2 = JHSchoolClass(name: "Test2", startDate: dateFromString(time: "07:56 AM"), endDate: dateFromString(time: "07:55 AM"), day: "A")
        let class3 = JHSchoolClass(name: "Test3", startDate: dateFromString(time: "10:57 AM"), endDate: dateFromString(time: "07:55 AM"), day: "A")
        let classes = [class2, class3, class1]
        tableView.getData()
        tableView.schedule.classes = classes
        tableView.schedule.sortClassesByStartTime()
        let ordered = tableView.schedule.classes
        XCTAssertTrue(ordered?[0].name == "Test1" && ordered?[1].name == "Test2" && ordered?[2].name == "Test3", "Not Ordered Correctly, correct order: \(class1.name), \(class2.name), \(class3.name), you had: \(ordered?[0].name), \(ordered?[1].name), \(ordered?[2].name)")
    }
    
    func testClassOrderByDay() {
        let class1 = JHSchoolClass(name: "Test1", startDate: dateFromString(time: "07:55 AM"), endDate: dateFromString(time: "07:55 AM"), day: "A")
        let class2 = JHSchoolClass(name: "Test2", startDate: dateFromString(time: "07:56 AM"), endDate: dateFromString(time: "07:55 AM"), day: "B")
        let class3 = JHSchoolClass(name: "Test3", startDate: dateFromString(time: "10:57 AM"), endDate: dateFromString(time: "07:55 AM"), day: "B")
        let classes = [class2, class3, class1]
        tableView.getData()
        tableView.schedule.classes = classes
        tableView.schedule.sortClassesByStartTime()
        let ordered = tableView.schedule.classesSortedByDay()
        XCTAssertTrue(ordered["A"]!.count == 1, "\(ordered["A"]!.count) A day objects, there should be 1")
        XCTAssertTrue(ordered["B"]![1].name == "Test3", "Second B day class is \(ordered["B"]![0].name), should be Test3")
    }
    
    func testGetEndTimes() {
        tableView.parseScheduleJSON()
        let endTime = tableView.schedule.classEndTimes()
        print(endTime)
        XCTAssertTrue(endTime.count == 5, "Incorrectly sorted end times: \(endTime.count)")
    }
    
    func testStringParser() {
        let string = "class=\"AP Calculus\" name=\"Read\" dueDate=\"04/15/2017\" timeToComplete=\"01:15\""
        let values: [String: String] = delegate.parseNotificationString(string: string)
        XCTAssertTrue(values["class"] == "AP Calculus", "class arg has \"\(values["class"])\" as content when it should have \"AP Calculus\"")
        XCTAssertTrue(values["name"] == "Read", "name arg has \"\(values["name"])\" as content when it should have \"Read\"")
        XCTAssertTrue(values["dueDate"] == "04/15/2017", "dueDate arg has \"\(values["dueDate"])\" as content when it should have \"04/15/2017\"")
        XCTAssertTrue(values["timeToComplete"] == "01:15", "timeToComplete arg has \"\(values["timeToComplete"])\" as content when it should have \"01:15\"")
    }
    
    func testCreateTaskFromArgs() {
        let args = [
            "class": "Physics",
            "name": "Homework",
            "dueDate": "04/21/2017",
            "timeToComplete" : "01:19"
        ]
        let (task, clas) = delegate.createTaskFromArgs(args: args)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let cDueDate = dateFormatter.date(from: "04/21/2017")
        XCTAssertTrue(task.name == "Homework", "Task name is \(task.name), it should be Homework")
        XCTAssertTrue(clas == "Physics", "Class name is \(clas), it should be Physics")
        let df = DateFormatter()
        df.dateStyle = .short
        XCTAssertTrue(cDueDate == task.dueDate, "Due date is \(df.string(from: task.dueDate)), should be 04/21/2017")
        let df3 = DateFormatter()
        df3.dateFormat = "hh:mm"
        let cTTC = df3.date(from: "01:19")
        let df2 = DateFormatter()
        df2.timeStyle = .short
        XCTAssertTrue(cTTC == task.estimatedTimeToComplete, "Due date is \(df2.string(from: task.estimatedTimeToComplete)), should be 01:19)")
    }
    
}

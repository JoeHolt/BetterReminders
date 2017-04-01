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
        XCTAssertTrue(tableView.classes?.count == 10, "Parsing JSON brought \(tableView.classes?.count) classes, there should be 10)")
    }
    
    func testClassOrderByTime() {
        let class1 = JHSchoolClass(name: "Test1", startDate: dateFromString(time: "7:55"), endDate: dateFromString(time: "7:55"), day: "A")
        let class2 = JHSchoolClass(name: "Test2", startDate: dateFromString(time: "7:56"), endDate: dateFromString(time: "7:55"), day: "A")
        let class3 = JHSchoolClass(name: "Test3", startDate: dateFromString(time: "10:57"), endDate: dateFromString(time: "7:55"), day: "A")
        let classes = [class2, class3, class1]
        let ordered = tableView.sortClassesByStartTime(classes: classes)
        XCTAssertTrue(ordered[0].name == "Test1" && ordered[1].name == "Test2" && ordered[2].name == "Test3", "Not Ordered Correctly, correct order: \(class1.name), \(class2.name), \(class3.name), you had: \(ordered[0].name), \(ordered[1].name), \(ordered[2].name)")
    }
    
    func testClassOrderByDay() {
        let class1 = JHSchoolClass(name: "Test1", startDate: dateFromString(time: "7:55"), endDate: dateFromString(time: "7:55"), day: "A")
        let class2 = JHSchoolClass(name: "Test2", startDate: dateFromString(time: "7:56"), endDate: dateFromString(time: "7:55"), day: "B")
        let class3 = JHSchoolClass(name: "Test3", startDate: dateFromString(time: "10:57"), endDate: dateFromString(time: "7:55"), day: "B")
        let classes = [class2, class3, class1]
        let ordered = tableView.sortClassesByDay(classes: classes)
        XCTAssertTrue(ordered["A"]!.count == 1, "\(ordered["A"]!.count) A day objects, there should be 1")
        XCTAssertTrue(ordered["B"]![1].name == "Test3", "Second B day class is \(ordered["B"]![0].name), should be Test3")
    }
    
   
    
    
}

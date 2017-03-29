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
        basicSchoolClass = JHSchoolClass(name: "Test", startTime: String(), endTime: String(), day: "A")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJHSchoolClassInit() {
        XCTAssertTrue(basicSchoolClass.day == "A" || basicSchoolClass.day == "B")
    }
    
    func testLoadingOfJSON() {
        let data = tableView.loadJSON(fromFile: "TestJSON", ofType: "json")
        XCTAssertTrue(data!["People"].arrayValue.count == 2)
        XCTAssertTrue(data!["People"].arrayValue[0]["name"] == "Joe")
    }
    
    func testParseJSON() {
        tableView.parseScheduleJSON()
        XCTAssertTrue(tableView.classes?.count == 10)
    }
    
   
    
    
}

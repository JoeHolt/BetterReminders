//
//  JHHelper.swift
//  BetterReminders
//
//  Created by Joe Holt on 3/27/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import Foundation
import UserNotifications

extension String {
    //Returns the charachter at a given index from a string
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
    
}

func dateFromString(time: String) -> Date {
    //String must be in hh:mm a format
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "hh:mm a"
    return inputFormatter.date(from: time)!
}

func createNotification(title: String, body: String, launchDate date: Date, repeats: Bool, id: String)   {
    //Creates UNNotifications notification
    //let tenSec = Calendar.current.date(byAdding: .second, value: 10, to: date)
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: .current, from: date)
    let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second)
    let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
    let content = createNotificationContent(title: title, body: body, badge: 0)
    let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error: \(error)")
        }
    }
}

func createNotificationContent(title: String, body: String, badge: Int = 0) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.badge = 0
    content.sound = UNNotificationSound.default()
    return content
}

func createNotificationWithTextField(title: String, body: String, launchDate date: Date, repeats: Bool, requestId: String, actionId: String, textTitle: String, textButtonTitle: String, textPlaceholder: String, catagotyId: String, center: UNUserNotificationCenter, removePending: Bool = false)   {
    //Creates UNNotifications notification
    //let tenSec = Calendar.current.date(byAdding: .second, value: 10, to: date)
    let calendar = Calendar(identifier: .gregorian)
    let components = calendar.dateComponents(in: .current, from: date)
    let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: components.second)
    let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
    let content = createNotificationContent(title: title, body: body, badge: 0)
    content.categoryIdentifier = catagotyId
    let textInput = UNTextInputNotificationAction(identifier: actionId, title: textTitle, options: [], textInputButtonTitle: textButtonTitle, textInputPlaceholder: textPlaceholder)
    let catagory = UNNotificationCategory(identifier: catagotyId, actions: [textInput], intentIdentifiers: [], options: [])
    let request = UNNotificationRequest(identifier: requestId, content: content, trigger: trigger)
    if removePending {
        center.removeAllPendingNotificationRequests()
    }
    center.add(request)
    center.setNotificationCategories([catagory])
}

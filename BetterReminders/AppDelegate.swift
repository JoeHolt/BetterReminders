//
//  AppDelegate.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit
import UserNotifications

enum NotificationArgs: String {
    case Class = "class"
    case Name = "name"
    case DueDate = "dueDate"
    case TimeToComplete = "timeToComplete"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let center = UNUserNotificationCenter.current()
    let notificationArgs: [String] = []
    var window: UIWindow?
    var tasksToAdd: [[String: JHTask]] = []
    var args: [String: String] = ["class" : "","name": "","dueDate": "","timeToComplete": ""]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in }
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //If notificatoin was a homework notification with text box
        if response.actionIdentifier.contains("classFinshedAction") {
            let response = response as! UNTextInputNotificationResponse
            let (task, clas) = createTaskFromArgs(args: parseNotificationString(string: response.userText))
            tasksToAdd.append([clas: task])
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //After a notification is displayed, request it agaion after the next week day
        if notification.request.identifier.contains("classFinishedRequest") {
            let nextTrigger: Double!
            let oneMinute = 60.0 //Seconds
            let oneDay = 1440.0 //Minutes
            let weekDay = Calendar.current.component(.weekday, from: Date())
            var daysTillNextNotification: Double = 1.0
            switch weekDay {
            case 6:
                //Friday
                daysTillNextNotification = 3.0 //Trigger in 3 days - monday
            case 7:
                //Saturday
                daysTillNextNotification = 2.0 //Trigger in 2 days - monday
            default:
                daysTillNextNotification = 1.0
            }
            nextTrigger = oneMinute * oneDay * daysTillNextNotification
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: nextTrigger, repeats: false)
            
            let content = createNotificationContent(title: "Enter assigned homework", body: "class=\"Class\" \nname=\"Name\" \ndueDate=\"04/15/17\" \ntimeToComplete=\"01:15\"", badge: 0)
            content.categoryIdentifier = "classFinishedCatagory"
            
            let request = UNNotificationRequest(identifier: "classFinishedRequest", content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    /**
        Parses a notification string
        - parameter string: String to be parsed
        - returns: A dictionsary with keys as args and values as arg body
    */
    func parseNotificationString(string: String) -> [String: String]{
        //notification is in the format of: arg0="content" arg1="Content" arg2="content" etc
        
        var body: String = ""
        var argActive = false   //Sets if argument is been parsed
        var firstQuote = true   //Shows if first quote in block has passed
        var argStr = ""
        for char in Array(string.characters) {
            if argActive == false {
                if char != "=" {
                    argStr = argStr + String(char)
                } else {
                    argActive = true
                }
            } else {
                if char == "\"" {
                    if firstQuote {
                        firstQuote = false
                    } else {
                        firstQuote = true
                        argActive = false
                        args[argStr.trimmingCharacters(in: .whitespaces)] = body
                        body = ""
                        argStr = ""
                    }
                } else {
                    body += String(char)
                }
            }
        }
        return args
    }
    
    /**
        Creates a JHTask from given args
        - parameter args: Dictionary containing args as keys and bodies as values
        - returns: The JHTask created and the name of the class it belonds to
    */
    func createTaskFromArgs(args: [String: String]) -> (JHTask, String) {
        var name: String = "Untitled"
        var dueDate: Date = Date()
        let components = DateComponents(hour: 1, minute: 15)
        var timeToFinish: Date = Calendar.current.date(from: components)!
        var clas: String = "AP Calculus"
        for key in args.keys {
            switch key {
            case NotificationArgs.Class.rawValue:
                if args[key] != "" {
                    clas = args[key]!
                }
            case NotificationArgs.Name.rawValue:
                if args[key] != "" {
                    name = args[key]!
                }
            case NotificationArgs.DueDate.rawValue:
                if args[key] != "" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy"
                    if let dueDatex = formatter.date(from: args[key]!) {
                        dueDate = dueDatex
                    }
                }
            case NotificationArgs.TimeToComplete.rawValue:
                if args[key] != "" {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm"
                    if let TTF = formatter.date(from: args[key]!) {
                        timeToFinish = TTF
                    }
                }
            default:
                break
            }
        }
        return (JHTask(name: name, completed: false, dueDate: dueDate, estimatedTimeToComplete: timeToFinish), clas)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


//
//  AppDelegate.swift
//  BetterReminders
//
//  Created by Joe Holt on 2/28/17.
//  Copyright © 2017 Joe Holt. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let center = UNUserNotificationCenter.current()
    let notificationArgs: [String] = []
    var window: UIWindow?
    var tasksToAdd = [JHTask]()
    var args: [String: String] = ["class" : "","name": "","dueDate": "","timeToComplete": ""]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        center.delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "classFinshedAction" { //Action id
            //Class finished notiication response
            let response = response as! UNTextInputNotificationResponse
            parseNotificationString(string: response.userText)
        }
        completionHandler()
    }
    
    func parseNotificationString(string: String) -> [String: String]{
        //notification is in the format of: arg0="content" arg1="Content" arg2="content" etc
        //Returns a dictionary with the args as keys and the value as the content
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


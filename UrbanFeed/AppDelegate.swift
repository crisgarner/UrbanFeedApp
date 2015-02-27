//
//  AppDelegate.swift
//  UrbanFeed
//
//  Created by Cristian Garner on 2/21/15.
//  Copyright (c) 2015 Cristian Garner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        
        // Register for Push Notitications, if running iOS 8
        let defaults = NSUserDefaults.standardUserDefaults()
        if let identifier = defaults.stringForKey("UserIdentifier"){
            //Do nothing
        }else{
            defaults.setObject(UIDevice.currentDevice().identifierForVendor.UUIDString, forKey: "UserIdentifier")
        }
        
        Parse.setApplicationId("mszxzS42wKud0ojfP0jJr8klsNCT9k8Js9JMf6ZW", clientKey: "LoKFBy77s096yqhzemww64qtVyzrk1obtEAkHRHK")
        var notificationType: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        
        var settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        // Override point for customization after application launch.
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        return true
    }
    
    //Push notifications
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings!) {
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println(error.localizedDescription)
        println("could not register: \(error)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let identifier = defaults.stringForKey("UserIdentifier"){
            currentInstallation["userIdentifier"] = identifier

        }
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


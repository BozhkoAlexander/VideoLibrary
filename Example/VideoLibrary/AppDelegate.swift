//
//  AppDelegate.swift
//  VideoLibrary
//
//  Created by BozhkoAlexander on 08/29/2018.
//  Copyright (c) 2018 BozhkoAlexander. All rights reserved.
//

import UIKit
import VideoLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    open class var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }
    
    var window: UIWindow?
    
    // MARK: - Navigation
    
    func restart() {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
            window.rootViewController = NavigationController.home
        }, completion: nil)
    }
    
    // MARK: - Application delegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = NavigationController.home
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Video.shared.resignActive()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        Video.shared.didBecomeActive()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

//
//  AppDelegate.swift
//  NightLight
//
//  Created by Dan on 10/3/19.
//  Copyright © 2019 Dan Panzarella. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var vc: ViewController?
    var shortcutAction: UIApplicationShortcutItem?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            shortcutAction = shortcutItem
        }
        
        // set prefs defaults
        UserDefaults.standard.register(defaults: [
            "host": "http://stop.light"
        ])
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let w = window {
            print("launching")
            vc = ViewController()
            w.backgroundColor = UIColor.gray
            navigationController = UINavigationController(rootViewController: vc!)
            w.rootViewController = navigationController
            w.makeKeyAndVisible()
            
        } else {
            print("not window?")
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Alternatively, a shortcut item may be passed in through this delegate method if the app was
        // still in memory when the Home screen quick action was used. Again, store it for processing.
        shortcutAction = shortcutItem
    }
    
}


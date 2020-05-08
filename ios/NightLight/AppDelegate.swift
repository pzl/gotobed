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
    
        vc = ViewController()
        if let w = window {
            print("launching")
            w.backgroundColor = UIColor.gray
            w.rootViewController = vc
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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("became active")
        vc?.hideFail()
        vc?.getState { [weak self] state in
            DispatchQueue.main.async {
                self?.vc?.stopspin()
            }
            if var state = state {
                if let action = self?.shortcutAction {
                    switch action.type {
                    case "Lamp": state.lamp = !state.lamp
                    default: print("unknown action: \(action.type)")
                    }
                
                    // Reset the shorcut item so it's never processed twice.
                    self?.shortcutAction = nil
                }
                
                self?.vc?.handleState(state)
            } else {
                DispatchQueue.main.async {
                    self?.vc?.showFail()
                }
                print("failed to fetch")
            }
        }
    }

}


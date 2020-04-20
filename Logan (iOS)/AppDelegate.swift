//
//  AppDelegate.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/4/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import UserNotifications
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DataManagerListener {
    
    var window: UIWindow?
    var newTaskViewController: NewTaskTableViewController?
    var newAssignmentViewController: NewAssignmentTableViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance()?.clientID = "261132618985-tc7m4hmblqvdtpbsij92b32o0m0r8pln.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = SignInManager.shared
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        NotificationManager.shared.confirmAuthorization()
        
        DataManager.shared.addListener(self)
        DataManager.shared.attemptInitialDataFetch()
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            handleShortcut(shortcutItem)
        }
        
        if let tabController = window?.rootViewController as? UITabBarController {
            for controller in tabController.viewControllers ?? [] {
                controller.loadViewIfNeeded()
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "logan" {}
        else {
            return GIDSignIn.sharedInstance()?.handle(url) ?? true
        }
        
        return true
    }
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem, completionHandler: ((Bool) -> Void)? = nil) {
        if let shortcutIdentifier = shortcutItem.type.components(separatedBy: ".").last {
            if shortcutIdentifier == "introduction" {
                UserDefaults.standard.set(false, forKey: "Introduction Completed")
                UserDefaults.standard.synchronize()
            } else if shortcutIdentifier == "newTask" {
                (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
                
                if let navigationController = UIStoryboard(name: "Tasks", bundle: Bundle.main).instantiateViewController(withIdentifier: "New Task Navigation Controller") as? BetterNavigationController {
                    if let newTaskViewController = navigationController.topViewController as? NewTaskTableViewController {
                        self.newTaskViewController = newTaskViewController
                        newTaskViewController.tableView.isUserInteractionEnabled = false
                        
                        window?.rootViewController?.present(navigationController, animated: true, completion: {
                            completionHandler?(true)
                        })
                    }
                }
            } else if shortcutIdentifier == "newAssignment" {
                (window?.rootViewController as? UITabBarController)?.selectedIndex = 2
                
                if let navigationController = UIStoryboard(name: "Assignments", bundle: Bundle.main).instantiateViewController(withIdentifier: "New Assignment Navigation Controller") as? BetterNavigationController {
                    if let newAssignmentViewController = navigationController.topViewController as? NewAssignmentTableViewController {
                        self.newAssignmentViewController = newAssignmentViewController
                        newAssignmentViewController.tableView.isUserInteractionEnabled = false
                        
                        window?.rootViewController?.present(navigationController, animated: true, completion: {
                            completionHandler?(true)
                        })
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        handleShortcut(shortcutItem, completionHandler: completionHandler)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        DataManager.shared.fetchDataFromCloud()
    }
    
    // MARK: - DataManagerListener
    
    func handleLoadingEvent(_ eventType: DataManager.LoadingEventType, error: Error?) {
        if eventType == .end {
            newTaskViewController?.tableView.isUserInteractionEnabled = true
            newAssignmentViewController?.tableView.isUserInteractionEnabled = true
        } else if eventType == .error {
            newTaskViewController?.navigationController?.dismiss(animated: true, completion: nil)
            newAssignmentViewController?.navigationController?.dismiss(animated: true, completion: nil)
            
            let alertController = UIAlertController(title: "iCloud Sync Error", message: "There was an error connecting to iCloud. Until it is resolved, no changes made will be saved.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            window?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }

}

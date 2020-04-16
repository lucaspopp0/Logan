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
class AppDelegate: UIResponder, UIApplicationDelegate, DataManagerListener, GIDSignInDelegate {
    
    var window: UIWindow?
    var newTaskViewController: NewTaskTableViewController?
    var newAssignmentViewController: NewAssignmentTableViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GIDSignIn.sharedInstance()?.clientID = "261132618985-tc7m4hmblqvdtpbsij92b32o0m0r8pln.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
        
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
    
    // MARK: - Google Sign-In
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            
            return
        }
        
        guard let idToken = user.authentication.idToken else {
            print("Google Sign-In Error: Missing id token")
            return
        }
        
        let url = URL(string: "http://logan-backend.us-west-2.elasticbeanstalk.com/auth")!
        let body = try? JSONSerialization.data(withJSONObject: [ "idToken": idToken ])
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("ios", forHTTPHeaderField: "Client-Type")
        request.httpMethod = "POST"
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                if let bearer: String = responseJSON["bearer"] as? String {
                    print("Bearer token obtained from backend")
                } else {
                    print("No bearer token. Response:")
                    print(responseJSON)
                }
            }
        }
        
        task.resume()
        
//        async function establishAuth(idToken) {
//            if (process.env.NODE_ENV == 'production') {
//                const { bearer } = await execute('post', '/auth', { idToken }, true);
//                BEARER = bearer;
//            } else {
//                BEARER = 'DEV lmp122@case.edu';
//            }
//        }
        
        print("Signed in as \(user.profile.name!)!")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Sign out
    }

}

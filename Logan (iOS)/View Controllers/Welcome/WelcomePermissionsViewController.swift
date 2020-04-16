//
//  WelcomePermissionsViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import GoogleSignIn

class WelcomePermissionsViewController: UIViewController {
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var iCloudButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        iCloudButton.setTitle("Set Up iCloud Drive", for: UIControlState.normal)
        iCloudButton.setTitle("iCloud Drive Already Configured", for: UIControlState.disabled)
        notificationsButton.setTitle("Enable Push Notifications", for: UIControlState.normal)
        notificationsButton.setTitle("Push Notifications Already Enabled", for: UIControlState.disabled)
        
        iCloudButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        iCloudButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: UIControlState.disabled)
        notificationsButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        notificationsButton.setTitleColor(UIColor.black.withAlphaComponent(0.3), for: UIControlState.disabled)
        
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        CKContainer.default().accountStatus { (accountStatus, accountStatusError) in
            DispatchQueue.main.async {
                switch accountStatus {
                    
                case .available:
                    self.iCloudButton.isEnabled = false
                    break
                    
                default:
                    self.iCloudButton.isEnabled = true
                    break
                }
            }
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                self.notificationsButton.isEnabled = settings.authorizationStatus != UNAuthorizationStatus.authorized
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CKContainer.default().accountStatus { (accountStatus, accountStatusError) in
            DispatchQueue.main.async {
                switch accountStatus {
                    
                case .available:
                    self.iCloudButton.isEnabled = false
                    break
                    
                default:
                    self.iCloudButton.isEnabled = true
                    break
                }
            }
        }
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            DispatchQueue.main.async {
                self.notificationsButton.isEnabled = settings.authorizationStatus != UNAuthorizationStatus.authorized
            }
        }
    }
    
    @IBAction func enableCloud(_ sender: Any?) {
        CKContainer.default().accountStatus { (accountStatus, accountStatusError) in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                if let error = accountStatusError {
                    Console.shared.print("Account status error: \(error.localizedDescription)")
                }
                
                switch accountStatus {
                    
                case .available:
                    alert.title = "All Set!"
                    alert.message = "You already have iCloud Drive enabled."
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    break
                    
                case .couldNotDetermine:
                    alert.title = "Set Up iCloud Drive"
                    alert.message = "There was a problem communicating with iCloud. Please make sure that iCloud Drive is set up so I can save your data!"
                    alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }))
                    break
                    
                case .restricted:
                    alert.title = "Set Up iCloud Drive"
                    alert.message = "iCloud is not available due to Parental Controls. Please enable iCloud Drive so I can save your data!"
                    alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }))
                    break
                    
                case .noAccount:
                    alert.title = "Set Up iCloud Drive"
                    alert.message = "You currently do not have an iCloud account set up on this device. Please set up iCloud and enable iCloud Drive so I can save your data!"
                    alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertActionStyle.cancel, handler: nil))
                    alert.addAction(UIAlertAction(title: "Open Settings", style: UIAlertActionStyle.default, handler: { (action) in
                        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }))
                    break
                }
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func enableNotifications(_ sender: Any?) {
        let preRequestAlert = UIAlertController(title: "Enable Notifications", message: "I need permission to send you reminders. The only notifications you'll ever get are the ones you schedule yourself.", preferredStyle: UIAlertControllerStyle.alert)
        preRequestAlert.addAction(UIAlertAction(title: "Not Now", style: UIAlertActionStyle.cancel, handler: nil))
        preRequestAlert.addAction(UIAlertAction(title: "Enable", style: UIAlertActionStyle.default, handler: { (action) in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (authorizationGranted, error) in
                DispatchQueue.main.async {
                    if let authorizationError = error {
                        Console.shared.print("Error authorizing notifications: \(authorizationError.localizedDescription)")
                    }
                    
                    if authorizationGranted {
                        self.notificationsButton.isEnabled = false
                        self.notificationsButton.setTitle("Push Notifications Enabled", for: UIControlState.disabled)
                    }
                }
            }
        }))
        
        present(preRequestAlert, animated: true, completion: nil)
    }
    
    @IBAction func didTapSignOut(_ sender: AnyObject) {
        GIDSignIn.sharedInstance()?.signOut()
    }
    
}

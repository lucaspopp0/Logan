//
//  SettingsTableViewController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 7/21/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit
import GoogleSignIn

class SettingsTableViewController: UITableViewController, SignInListener {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Settings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SignInManager.shared.addListener(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SignInManager.shared.removeListener(self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if SignInManager.shared.currentUser != nil {
                return 2
            } else {
                return 1
            }
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        if indexPath.section == 0 {
            if let user = SignInManager.shared.currentUser {
                if indexPath.row == 0 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Google User", for: indexPath)
                    cell.textLabel?.text = user.profile.name
                    cell.detailTextLabel?.text = user.profile.email
                } else if indexPath.row == 1 {
                    cell = tableView.dequeueReusableCell(withIdentifier: "Basic Button", for: indexPath)
                    cell.textLabel?.text = "Sign out"
                    cell.textLabel?.textColor = UIColor.red500
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "Basic Button", for: indexPath)
                
                cell.textLabel?.text = "Sign in"
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)
            
            if indexPath.section == 1 && indexPath.row == 0 {
                cell.textLabel?.text = "Calendars"
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            } else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "View Logs"
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Google Account"
        case 2:
            return "Developer"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == tableView.numberOfSections - 1 {
            return "© \(CalendarDay(date: Date()).year) Lucas Popp"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if section == tableView.numberOfSections - 1, let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = NSTextAlignment.center
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if SignInManager.shared.currentUser != nil {
                if indexPath.row == 1 {
                    GIDSignIn.sharedInstance()?.presentingViewController = self
                    GIDSignIn.sharedInstance()?.signOut()
                }
            } else if indexPath.row == 0 {
                GIDSignIn.sharedInstance()?.presentingViewController = self
                GIDSignIn.sharedInstance()?.signIn()
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "Edit Calendars", sender: self)
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "View Logs", sender: self)
            }
        }
    }
    
    // MARK: - SignInListener
    
    func signedIn() {
        tableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
    }
    
    func signedOut() {
        tableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
    }

}

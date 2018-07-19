//
//  ExtracurricularTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class ExtracurricularTableViewController: UITableViewController, UITextViewDelegate {

    var extracurricular: Extracurricular!
    
    private var nameView: UITextView!
    private var nicknameView: UITextView!
    private var colorSwatch: UIColorSwatch!
    private var colorPicker: UIColorPicker!
    
    private var colorPickerOpen: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = extracurricular.color
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParentViewController {
            navigationController?.navigationBar.barTintColor = UIColor.teal500
            
            DataManager.shared.update(extracurricular.record)
        }
    }
    
    @IBAction func toggleColorPicker(_ sender: UIColorSwatch) {
        tableView.beginUpdates()
        colorPickerOpen = !colorPickerOpen
        tableView.endUpdates()
    }
    
    @IBAction func colorPicked(_ sender: UIColorPicker) {
        extracurricular.color = sender.colorValue
        colorSwatch.colorValue = sender.colorValue
        navigationController?.navigationBar.barTintColor = sender.colorValue
        
        tableView.reloadRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 1) - 1, section: 1)], with: UITableViewRowAnimation.automatic)
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        
        extracurricular.name = nameView.text
        extracurricular.nickname = nicknameView.text
        
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1 + extracurricular.events.count
        } else if section == 2 {
            return 1
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Name", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    nameView = textView
                    nameView.text = extracurricular.name
                }
                
                if let colorSwatch = cell.viewWithTag(2) as? UIColorSwatch {
                    self.colorSwatch = colorSwatch
                    colorSwatch.colorValue = extracurricular.color
                }
                
                if let colorPicker = cell.viewWithTag(3) as? UIColorPicker {
                    self.colorPicker = colorPicker
                }
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Nickname", for: indexPath)
                
                if let textView = cell.viewWithTag(1) as? UITextView {
                    nicknameView = textView
                    nicknameView.text = extracurricular.nickname
                }
                
                return cell
            }
        } else if indexPath.section == 1 {
            if indexPath.row == extracurricular.events.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Add Event", for: indexPath)
                cell.textLabel?.textColor = extracurricular.color
                return cell
            } else {
                let event = extracurricular.events[indexPath.row]
                
                if event is SingleEvent, let cell = tableView.dequeueReusableCell(withIdentifier: "Single Event", for: indexPath) as? SingleEventTableViewCell {
                    cell.event = event as! SingleEvent
                    
                    return cell
                } else if event is RepeatingEvent, let cell = tableView.dequeueReusableCell(withIdentifier: "Repeating Event", for: indexPath) as? RepeatingEventTableViewCell {
                    cell.event = event as! RepeatingEvent
                    
                    return cell
                }
            }
        } else if indexPath.section == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "Delete", for: indexPath)
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            if tableView.cellForRow(at: indexPath) != nil {
                if colorPickerOpen {
                    return colorPicker.frame.maxY + 15
                } else {
                    return nameView.superview!.frame.maxY + 12
                }
            } else if let cell = tableView.dequeueReusableCell(withIdentifier: "Name") {
                (cell.viewWithTag(1) as? UITextView)?.text = extracurricular.name
                
                cell.updateConstraints()
                cell.layoutIfNeeded()
                
                if colorPickerOpen {
                    return cell.viewWithTag(3)!.frame.maxY + 15
                } else {
                    return cell.viewWithTag(1)!.superview!.frame.maxY + 12
                }
            }
        }
        
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Events"
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 && indexPath.row < tableView.numberOfRows(inSection: 1) - 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DataManager.shared.delete(extracurricular.events[indexPath.row].record)
            extracurricular.events.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Add Single Event", style: UIAlertActionStyle.default, handler: { (_) in
                self.performSegue(withIdentifier: "New Single Event", sender: self)
            }))
            actionSheet.addAction(UIAlertAction(title: "Add Repeating Event", style: UIAlertActionStyle.default, handler: { (_) in
                self.performSegue(withIdentifier: "New Repeating Event", sender: self)
            }))
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            present(actionSheet, animated: true, completion: nil)
        } else if indexPath.section == 2 {
            let alert = UIAlertController(title: "Delete \(extracurricular.shorterName)", message: "Are you sure? This action cannot be undone.", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                tableView.deselectRow(at: indexPath, animated: true)
                
                if let index = DataManager.shared.extracurriculars.index(of: self.extracurricular) {
                    DataManager.shared.delete(self.extracurricular.record)
                    DataManager.shared.extracurriculars.remove(at: index)
                }
                
                self.navigationController?.popViewController(animated: true)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventController = segue.destination as? EventTableViewController, let selectedIndexPath = tableView.indexPathForSelectedRow {
            eventController.event = extracurricular.events[selectedIndexPath.row]
        } else if let navigationController = segue.destination as? BetterNavigationController {
            if let newEventController = navigationController.topViewController as? NewEventTableViewController {
                newEventController.correspondingExtracurricular = extracurricular
                navigationController.barColor = extracurricular.color
            }
        }
    }

}

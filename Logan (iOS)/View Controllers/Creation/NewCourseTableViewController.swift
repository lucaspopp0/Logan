//
//  NewCourseTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewCourseTableViewController: CreationController {

    var correspondingSemester: Semester!
    var course: Course!
    
    @IBOutlet weak var nameView: UITextView!
    @IBOutlet weak var nicknameView: UITextView!
    @IBOutlet weak var descriptorField: UITextField!
    @IBOutlet weak var colorPicker: UIColorPicker!
    
    func setupInitialData() {
        course = Course(id: "newcourse", name: "", color: UIColor.black, semester: correspondingSemester!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        course.color = UIColor.red500
        colorPicker.colorValue = course.color
    }
    
    @IBAction override func done(_ sender: Any) {
        super.done(sender)
        
        view.endEditing(true)
        nameView.isEditable = false
        nicknameView.isEditable = false
        descriptorField.isEnabled = false
        colorPicker.isEnabled = false
        
        course.name = nameView.text
        course.nickname = nicknameView.text
        course.descriptor = descriptorField.text ?? ""
        
        API.shared.addCourse(course) { (success, blob) in
            if success {
                self.course.id = blob!["cid"] as! String
                self.correspondingSemester.courses.append(self.course)
            } else {
                print("Error adding course")
                // TODO: Alert user
            }
            
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = course.color
        
        if !alreadyOpened {
            alreadyOpened = true
            
            nameView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.teal500
    }
    
    @IBAction func colorPicked(_ sender: UIColorPicker) {
        course.color = sender.colorValue
        navigationController?.navigationBar.barTintColor = sender.colorValue
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        
        course.name = nameView.text
        course.nickname = nicknameView.text
        
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

//
//  NewCourseTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 1/11/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewCourseTableViewController: UITableViewController {

    var correspondingSemester: Semester!
    var course: Course = Course()
    
    @IBOutlet weak var nameView: UITextView!
    @IBOutlet weak var nicknameView: UITextView!
    @IBOutlet weak var descriptorField: UITextField!
    @IBOutlet weak var colorPicker: UIColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        course.color = UIColor.red500
        colorPicker.colorValue = course.color
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        course.name = nameView.text
        course.nickname = nicknameView.text
        course.descriptor = descriptorField.text ?? ""
        
        correspondingSemester.courses.append(course)
        
        DataManager.shared.introduce(course.record)
        DataManager.shared.update(correspondingSemester.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = course.color
        nameView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.barTintColor = UIColor.teal500
        
        DataManager.shared.update(course.record)
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

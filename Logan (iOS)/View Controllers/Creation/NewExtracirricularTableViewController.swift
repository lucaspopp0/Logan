//
//  NewExtracurricularTableViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/10/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class NewExtracurricularTableViewController: UITableViewController {

    var extracurricular = Extracurricular()
    
    @IBOutlet weak var nameView: UITextView!
    @IBOutlet weak var nicknameView: UITextView!
    @IBOutlet weak var colorPicker: UIColorPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extracurricular.color = UIColor.red500
        colorPicker.colorValue = extracurricular.color
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        extracurricular.name = nameView.text
        extracurricular.nickname = nicknameView.text
        
        DataManager.shared.extracurriculars.append(extracurricular)
        DataManager.shared.introduce(extracurricular.record)
        
        view.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.barTintColor = extracurricular.color
        nameView.becomeFirstResponder()
    }
    
    @IBAction func colorPicked(_ sender: UIColorPicker) {
        extracurricular.color = sender.colorValue
        navigationController?.navigationBar.barTintColor = sender.colorValue
    }
    
    // MARK: - Text view delegate
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        
        extracurricular.name = nameView.text
        extracurricular.nickname = nicknameView.text
        
        tableView.endUpdates()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

}

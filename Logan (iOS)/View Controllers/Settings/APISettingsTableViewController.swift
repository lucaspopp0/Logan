//
//  APISettingsTableViewController.swift
//  Logan (iOS)
//
//  Created by Lucas Popp on 9/16/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class APISettingsTableViewController: UITableViewController {
    
    var counters: [(String, Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        API.shared.fetchData { (completed, errors) in
            if errors.count == 0 {
                self.counters = []
                self.counters.append(("Tags", API.shared.tagMap.pairs.count))
                self.counters.append(("Semesters", API.shared.semesterMap.pairs.count))
                self.counters.append(("Courses", API.shared.courseMap.pairs.count))
                self.counters.append(("Sections", API.shared.sectionMap.pairs.count))
                self.counters.append(("Assessments", API.shared.assessmentMap.pairs.count))
                self.counters.append(("Assignments", API.shared.assignmentMap.pairs.count))
                self.counters.append(("Tasks", API.shared.taskMap.pairs.count))
                
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Basic Cell", for: indexPath)

        if let primaryLabel = cell.viewWithTag(1) as? UILabel, let secondaryLabel = cell.viewWithTag(2) as? UILabel {
            primaryLabel.text = counters[indexPath.row].0
            secondaryLabel.text = "\(counters[indexPath.row].1)"
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

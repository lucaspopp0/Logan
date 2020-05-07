//
//  WelcomeSemesterViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class WelcomeSemesterViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    let semester = Semester(id: "firstsemester", name: "", startDate: CalendarDay(date: Date()), endDate: CalendarDay(date: Date()))
    
    @IBOutlet weak var pageViewContainer: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    private var nameField: UITextField!
    private var startLabel: UILabel!
    private var startPicker: BetterDatePicker!
    private var endLabel: UILabel!
    private var endPicker: BetterDatePicker!
    
    var pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    private var pages: [UIViewController] = []
    
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let identifiers = ["Semester Name", "Semester Start", "Semester End"]
        
        for identifier in identifiers {
            let vc = UIStoryboard(name: "Welcome", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as UIViewController
            pages.append(vc)
            
            if identifier == "Semester Name" {
                if let textField = vc.view.viewWithTag(1) as? UITextField {
                    nameField = textField
                }
            } else if identifier == "Semester Start" {
                if let label = vc.view.viewWithTag(1) as? UILabel {
                    startLabel = label
                    startLabel.text = BetterDateFormatter.autoFormatDate(semester.startDate.dateValue!)
                }
                
                if let picker = vc.view.viewWithTag(2) as? BetterDatePicker {
                    startPicker = picker
                    startPicker.calendarDay = semester.startDate
                }
            } else if identifier == "Semester End" {
                if let label = vc.view.viewWithTag(1) as? UILabel {
                    endLabel = label
                    endLabel.text = BetterDateFormatter.autoFormatDate(semester.endDate.dateValue!)
                }
                
                if let picker = vc.view.viewWithTag(2) as? BetterDatePicker {
                    endPicker = picker
                    endPicker.calendarDay = semester.endDate
                }
            }
        }
        
        nameField.addTarget(self, action: #selector(self.updateName(_:)), for: UIControlEvents.editingChanged)
        startPicker.addTarget(self, action: #selector(self.semesterBoundChanged(_:)), for: UIControlEvents.valueChanged)
        endPicker.addTarget(self, action: #selector(self.semesterBoundChanged(_:)), for: UIControlEvents.valueChanged)
        
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        addChildViewController(pageController)
        pageViewContainer.addSubview(pageController.view)
        
        pageController.view.frame = pageViewContainer.bounds
        pageController.didMove(toParentViewController: self)
        
        nameField.becomeFirstResponder()
        nextButton.isEnabled = false
    }
    
    @IBAction func next(_ sender: Any?) {
        if presentationIndex(for: pageController) == 2 {
            API.shared.addSemester(semester) { (success, blob) in
                if success {
                    DataManager.shared.semesters.append(self.semester)
                    self.performSegue(withIdentifier: "Show Main Interface", sender: self)
                } else {
                    // TODO: Inform user
                }
            }
        } else if let currentController = pageController.viewControllers?.first, let index = pages.index(of: currentController), index + 1 < pages.count {
            pageController.setViewControllers([pages[index + 1]], direction: UIPageViewControllerNavigationDirection.forward, animated: true, completion: nil)
            
            if index == 1 {
                nextButton.setTitle("Done", for: UIControlState.normal)
            }
        }
    }
    
    @objc func updateName(_ sender: Any) {
        semester.name = nameField.text ?? ""
        
        nextButton.isEnabled = !semester.name.isEmpty
    }
    
    @objc func semesterBoundChanged(_ sender: BetterDatePicker) {
        if sender.isEqual(startPicker) {
            semester.startDate = sender.calendarDay
            startLabel.text = BetterDateFormatter.autoFormatDate(sender.dateValue)
        } else if sender.isEqual(endPicker) {
            semester.endDate = sender.calendarDay
            endLabel.text = BetterDateFormatter.autoFormatDate(sender.dateValue)
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let pendingController = pendingViewControllers.first, let index = pages.index(of: pendingController), index == 2 {
            nextButton.setTitle("Done", for: UIControlState.normal)
        } else {
            nextButton.setTitle("Next", for: UIControlState.normal)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if presentationIndex(for: pageViewController) == 2 {
            nextButton.setTitle("Done", for: UIControlState.normal)
        } else {
            nextButton.setTitle("Next", for: UIControlState.normal)
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        if let presentedController = pageViewController.viewControllers?.first, let index = pages.index(of: presentedController) {
            return index
        }
        
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.index(of: viewController) {
            if index > 0 {
                return pages[index - 1]
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.index(of: viewController) {
            if index + 1 < pages.count {
                if nextButton.isEnabled {
                    return pages[index + 1]
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabController = segue.destination as? UITabBarController {
            tabController.selectedIndex = 3
            
            if let semestersController = tabController.selectedViewController as? SemestersTableViewController {
                semestersController.updateData()
                semestersController.tableView.reloadData()
                semestersController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UITableViewScrollPosition.none)
            }
        }
    }
    
}

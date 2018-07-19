//
//  WelcomeViewController.swift
//  iOS Todo
//
//  Created by Lucas Popp on 3/9/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    @IBOutlet weak var pageViewContainer: UIView!
    
    var pageController: UIPageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.horizontal, options: nil)
    private var pages: [UIViewController] = []
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let identifiers = ["Welcome 1", "Welcome 2", "Commitments", "Assignments", "Tasks", "Permissions", "Get Started"]
        
        for identifier in identifiers {
            let vc = UIStoryboard(name: "Welcome", bundle: Bundle.main).instantiateViewController(withIdentifier: identifier) as UIViewController
            vc.view.backgroundColor = UIColor.clear
            pages.append(vc)
        }
        
        view.backgroundColor = UIColor.teal500
        pageController.view.backgroundColor = UIColor.teal500
        
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([pages[0]], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        addChildViewController(pageController)
        pageViewContainer.addSubview(pageController.view)
        
        pageController.view.frame = pageViewContainer.bounds
        pageController.didMove(toParentViewController: self)
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
                return pages[index + 1]
            }
        }
        
        return nil
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != nil && segue.identifier! == "Show Main Interface" {
            UserDefaults.standard.set(true, forKey: "Introduction Completed")
            UserDefaults.standard.synchronize()
        }
    }

}

//
//  WelcomeController.swift
//  Promised Land
//
//  Created by Dai Pham on 3/20/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import FirebaseDatabase

class WelcomeController: UIPageViewController {
    // MARK: - api
    
    // MARK: - private
    private func config() {
        
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.startLoading(activityIndicatorStyle: .gray, false)
        
        ref = Database.database().reference()
        ref.child("Welcome").observeSingleEvent(of: .value, with: { (snapshot) in
            var imageURLs = [String]()
            for snap in snapshot.children  {
                if let s = snap as? DataSnapshot, let json = s.value as? JSON {
                    if let data = json["Url"] as? String {
                        imageURLs.append(data)
                    }
                }
            }
            self.loaddata(imageURLs: imageURLs)
        }, withCancel: { (error) in
            print("error: \(error)")
        })
        
        dataSource = self
    }
    
    private func loaddata(imageURLs:[String]) {
        view.stopLoading()
        orderedViewControllers.removeAll()
        for (i,url) in imageURLs.enumerated() {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "imageViewController") as! ImageViewController
            vc.imageUrl = url
            vc.isShowButtonPlay = i == imageURLs.count - 1
            orderedViewControllers.append(vc)
        }
        
        if orderedViewControllers.count == 0 {return}
        
        if self.pageControl == nil {
            self.pageControl = UIPageControl(frame: view.bounds)
            self.pageControl.translatesAutoresizingMaskIntoConstraints = false
            self.pageControl.numberOfPages = orderedViewControllers.count
            self.pageControl.backgroundColor = UIColor.clear
            pageControl.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
            pageControl.pageIndicatorTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.view.addSubview(self.pageControl)
            if #available(iOS 11.0, *) {
                pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            } else {
                pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            }
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        }
        
        setViewControllers([orderedViewControllers.first!],
                           direction: .forward,
                           animated: true,
                           completion: nil)
    }
    
    // MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.child("Welcome").removeAllObservers()
    }
    
    // MARK: - closures
    
    // MARK: - properties
    var orderedViewControllers:[UIViewController] = []
    var ref: DatabaseReference!
    var pageControl:UIPageControl!
    
    // MARK: - outlet
}

extension WelcomeController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        pageControl.currentPage = viewControllerIndex
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        pageControl.currentPage = viewControllerIndex
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}

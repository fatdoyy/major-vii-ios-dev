//
//  EventSearchViewController.swift
//  major-7-ios
//
//  Created by jason on 21/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class EventSearchViewController: UIViewController {
    static let storyboardID = "eventsSearchVC"
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pumpkin
        setupLeftBarItems()
    }
    
}

//MARK: UI related
extension EventSearchViewController {
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: UIScreen.main.bounds.width, height: 30))
        customView.backgroundColor = .clear
        
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(backBtn)
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: backBtn.frame.maxX + 20, y: -7, width: UIScreen.main.bounds.width - 30, height: 44)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .whiteText()
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.text = "Search for events"
        customView.addSubview(titleLabel)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 32 - 40)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }

    @objc private func popView() {
        //navigationController?.hero.navigationAnimationType = .uncover(direction: .down)
        navigationController?.popViewController(animated: true)
    }

}

// MARK: function to push this view controller
extension EventSearchViewController {
    static func push(from view: UIViewController, eventID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: EventSearchViewController.storyboardID) as! EventSearchViewController
        
        view.navigationItem.title = ""
        view.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        view.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    static func present(from view: UIViewController, eventID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: EventSearchViewController.storyboardID) as! EventSearchViewController
        
        detailsVC.hero.isEnabled = true
        detailsVC.hero.modalAnimationType = .autoReverse(presenting: .zoom)
        view.present(detailsVC, animated: true, completion: nil)
    }
}

//
//  BuskerProfileEditViewController.swift
//  major-7-ios
//
//  Created by jason on 23/9/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerProfileEditViewController: UIViewController {
    static let storyboardID = "buskerProfileEditVC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pumpkin
        
        if #available(iOS 13.0, *) {} else {
            setupLeftBarItems()
        }
    }

}

//MARK: - UI related
extension BuskerProfileEditViewController {
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menuBtn.setImage(UIImage(named: "icon_close"), for: .normal)
        menuBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        customView.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(30)
        }
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Function to push/present this view controller
extension BuskerProfileEditViewController {
    static func push(from view: UIViewController, buskerName: String, buskerID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: BuskerProfileEditViewController.storyboardID) as! BuskerProfileEditViewController
        
        //profileVC.buskerID = buskerID
        //profileVC.buskerName = buskerName
        
        view.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        view.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    static func present(from view: UIViewController, buskerName: String, buskerID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: BuskerProfileEditViewController.storyboardID) as! BuskerProfileEditViewController
        
        //profileVC.buskerID = buskerID
        //profileVC.buskerName = buskerName
        
//        profileVC.hero.isEnabled = true
//        profileVC.hero.modalAnimationType = .autoReverse(presenting: .zoom)
        view.present(profileVC, animated: true, completion: nil)
    }
}

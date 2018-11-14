//
//  EventDetailsViewController.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

protocol EventDetailsDelegate {
}

class EventDetailsViewController: UIViewController {
    
    static let storyboardId = "eventDetails"

    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerImg.image = UIImage(named: "cat")
        mainScrollView.contentSize = CGSize(width: mainScrollView.contentSize.width, height: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainScrollView.contentInset = UIEdgeInsets(top: 280, left: 0, bottom: 0, right: 0)
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.barTintColor = .darkGray()
        navigationController?.navigationBar.isTranslucent = true
        TabBar.hide(rootView: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBar.show(rootView: self)
    }
}

//function to push this view controller
extension EventDetailsViewController{
    static func push(fromView: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVc = storyboard.instantiateViewController(withIdentifier: EventDetailsViewController.storyboardId)
        
        fromView.navigationItem.title = ""
        fromView.navigationController?.pushViewController(detailsVc, animated: true)
    }
}

//
//  TabBarViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// iOS 13 auto adjusts image insets if tab bar doesn't have a title, so we disable the image insets on iOS 13
        if #available(iOS 13.0, *) {
            if let items = self.tabBar.items {
                for item in items {
                    item.imageInsets = .zero
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

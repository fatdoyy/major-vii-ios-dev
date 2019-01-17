//
//  SettingsViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var logInOrOutBtn: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        if UserService.User.isLoggedIn() {
            logInOrOutBtn.setTitle("Log Out", for: .normal)
        } else {
            logInOrOutBtn.setTitle("Log In", for: .normal)
        }
        

        // Do any additional setup after loading the view.
    }


    @IBAction func didTapLogInOrOutBtn(_ sender: Any) {
        if logInOrOutBtn.title(for: .normal) == "Log In" {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            self.present(loginVC, animated: true, completion: nil)
            logInOrOutBtn.setTitle("Log Out", for: .normal)
        } else {
            UserService.User.logOut(fromVC: self)
            logInOrOutBtn.setTitle("Log In", for: .normal)
        }
    }
}

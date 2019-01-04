//
//  LoginViewController.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginView: LoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
    }

}

extension LoginViewController: LoginViewDelegate {
    
    //fb login
    func fbLoginPressed() {
        UserService.FB.login(fromVc: self)
    }
    
    //google login
}

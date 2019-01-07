//
//  LoginViewController.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginView: LoginView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        UserService.sharedInstance.delegate = self
        loginView.delegate = self
    }

}

extension LoginViewController: LoginViewDelegate, UserServiceDelegate {

    //fb login
    func fbLoginPressed() {
        UserService.FB.login(fromVc: self)
    }
    
    //google login
    func googleLoginPressed() {
        UserService.Google.login(fromVc: self)
        //UserService.login(fromVc: self)
    }
    
    func googleLoginPresent(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func googleLoginDismiss(_ viewController: UIViewController) {
        self.dismiss(animated: true, completion: nil)
    }

}

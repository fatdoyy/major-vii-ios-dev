//
//  LoginViewController.swift
//  major-7-ios
//
//  Created by jason on 3/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Bartinter
import GoogleSignIn

class LoginViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBOutlet weak var loginView: LoginView!
    
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dismissLoginVC), name: .completedLogin, object: nil)
        updatesStatusBarAppearanceAutomatically = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadGIF()
    }
    
    private func loadGIF() {
        let gifIndex = loginView.gifIndex
        loginView.videoBg.loadGif(name: gifIndex ?? "")
    }
    
    @objc func dismissLoginVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LoginViewController: LoginViewDelegate, UserServiceDelegate {

    //fb login
    func fbLoginPressed() {
        UserService.FB.login(fromVC: self)
    }
    
    //google login
    func googleLoginPressed() {
        userService.delegate = self
        UserService.Google.login(fromVC: self)
        //UserService.login(fromVc: self)
    }
    
    func googleLoginPresent(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }

    func googleLoginDismiss(_ viewController: UIViewController) {
        self.dismiss(animated: true, completion: nil)
    }

    func googleLoginWillDispatch() {
        print("1234567")
    }
    
}

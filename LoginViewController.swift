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
        if UIScreen.main.nativeBounds.height != 1136 { // not loading GIFs on iPhone SE becasue of performance issue
            loadGIF()
        }
    }
    
    private func loadGIF() {
        if let gifIndex = loginView.gifIndex {
            loginView.videoBg.loadGif(name: gifIndex)
        }
    
        loginView.layoutIfNeeded()
    }
    
    @objc func dismissLoginVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension LoginViewController: LoginViewDelegate, UserServiceDelegate {
    
    //fb login
    func didTapFbLogin() {
        UserService.FB.login(fromVC: self)
    }
    
    //google login
    func didTapGoogleLogin() {
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
    
    //email login
    func didTapEmailLogin() {
        for view in loginView.socialLoginElements {
            if view.alpha != 0 {
                loginView.emailLoginBtn.setTitle("使用其他方法登入", for: .normal)
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 0
                    view.isUserInteractionEnabled = false
                }
            } else {
                loginView.emailLoginBtn.setTitle("已經有Account? 立即登入！", for: .normal)
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 1
                    view.isUserInteractionEnabled = true
                }
            }
        }
        
    }
    
}

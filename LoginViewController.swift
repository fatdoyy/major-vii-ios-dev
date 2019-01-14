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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(loginView) // also remove observer in LoginView.swift
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
    
    //register btn, NOTE: not register action
    func didTapRegisterBtn() {
        //hide social login elements
        for view in loginView.socialLoginElements {
            loginView.emailLoginBtn.setTitle("使用其他方法登入", for: .normal)
            UIView.animate(withDuration: 0.2) {
                view.alpha = 0
                view.isUserInteractionEnabled = false
            }
        }
        
        //show register elements
        for view in loginView.registerElements {
            loginView.regActionBtnGradientBg.startAnimation()
            UIView.animate(withDuration: 0.2) {
                view.alpha = 1
                view.isUserInteractionEnabled = true
            }
        }
    }
    
    
    //email login
    func didTapEmailLogin() {
        if loginView.emailLoginBtn.title(for: .normal) == "已經有Account? 立即登入！" {
            //hide social login elements
            for view in loginView.socialLoginElements {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 0
                    view.isUserInteractionEnabled = false
                }
            }
            
            //show email login elements
            loginView.loginActionBtnGradientBg.startAnimation()
            for view in loginView.emailLoginElements {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 1
                    view.isUserInteractionEnabled = true
                }
            }
            
            loginView.emailLoginBtn.setTitle("使用其他方法登入", for: .normal)
        } else {
            //hide register elements
            for view in loginView.registerElements {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 0
                    view.isUserInteractionEnabled = false
                }
            }
            
            //hide email login elements
            for view in loginView.emailLoginElements {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 0
                    view.isUserInteractionEnabled = false
                }
            }
            
            //show social login elements
            for view in loginView.socialLoginElements {
                UIView.animate(withDuration: 0.2) {
                    view.alpha = 1
                    view.isUserInteractionEnabled = true
                }
            }
            
            loginView.emailLoginBtn.setTitle("已經有Account? 立即登入！", for: .normal)
        }
    }
    
    
    func didTapLoginAction() {
        
    }
    
}

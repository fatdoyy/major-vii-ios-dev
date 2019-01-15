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
import NVActivityIndicatorView

class LoginViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    @IBOutlet weak var loginView: LoginView!
    
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(dismissLoginVC), name: .loginCompleted, object: nil)
        updatesStatusBarAppearanceAutomatically = true
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.main.nativeBounds.height != 1136 { // not loading GIFs on iPhone SE becasue of performance issue
            loadGIF()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
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

//MARK: Login / Register Delegate
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
    
    //email login, NOTE: not email action
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
    
    //email login
    func didTapLoginAction() {
        if let email = loginView.emailTextField.text, let password = loginView.pwTextField.text{
            if email != "" && password != "" {
                //hide button title and show indicator
                loginView.loginActionBtn.isUserInteractionEnabled = false
                UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.loginActionBtn.setTitle("", for: .normal)
                }, completion: nil)
                
                //show indicator
                UIView.animate(withDuration: 0.2) {
                    self.loginView.loginActivityIndicator.startAnimating()
                    self.loginView.loginActivityIndicator.alpha = 1
                }
                
                //login action
                UserService.Email.login(email: email, password: password, loginView: loginView)
            } else {
                print("email / password empty?")
                
                loginView.loginActionBtn.isUserInteractionEnabled = false
                //animate title change to error msg
                UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.loginActionBtn.setTitle("冇入野喎", for: .normal)
                    self.loginView.loginActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                }, completion: nil)
                
                //reset button state
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    UIView.transition(with: self.loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.loginActionBtn.setTitle("登入", for: .normal)
                        self.loginView.loginActionBtn.setTitleColor(.whiteText(), for: .normal)
                    }, completion: nil)
                    
                    self.loginView.loginActionBtn.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    //register section
    func didTapRegAction() {
        if let email = loginView.regEmailTextField.text, let password = loginView.regPwRefillTextField.text{
            if email != "" && password != "" {
                //hide button title and show indicator
                loginView.regActionBtn.isUserInteractionEnabled = false
                UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.regActionBtn.setTitle("", for: .normal)
                }, completion: nil)
                
                //show indicator
                UIView.animate(withDuration: 0.2) {
                    self.loginView.regActivityIndicator.startAnimating()
                    self.loginView.regActivityIndicator.alpha = 1
                }
                
                //register action
                UserService.Email.register(email: email, password: password, loginView: loginView)
            } else {
                print("email / password empty?")
                
                loginView.regActionBtn.isUserInteractionEnabled = false
                //animate title change
                UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.regActionBtn.setTitle("冇入野喎", for: .normal)
                    self.loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                }, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.regActionBtn.setTitle("登入", for: .normal)
                        self.loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                    }, completion: nil)
                    self.loginView.regActionBtn.isUserInteractionEnabled = true
                }
            }
        }
    }
    
}

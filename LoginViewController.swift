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
import Validator

class LoginViewController: UIViewController {
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    @IBOutlet weak var loginView: LoginView!
    
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
        NotificationCenter.default.setObserver(self, selector: #selector(dismissLoginVC), name: .loginCompleted, object: nil)
        updatesStatusBarAppearanceAutomatically = true
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.main.nativeBounds.height != 1136 { // not loading GIFs on iPhone SE becasue of performance issue
            loadGIF()
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(loginView) // also remove observer in LoginView.swift
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if !self.isModal { //send notification to refresh EventListViewController
            if UserService.User.isLoggedIn() {
                NotificationCenter.default.post(name: .refreshEventListVC, object: nil)
            }
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
            if self.isModal {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: Login / Register Delegate
extension LoginViewController: LoginViewDelegate, UserServiceDelegate {
    
    func didTapDismissBtn(){
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    //fb login
    func didTapFbLogin() {
        UserService.FB.logIn(fromVC: self)
    }
    
    //google login
    func didTapGoogleLogin() {
        userService.delegate = self
        UserService.Google.logIn(fromVC: self)
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
    
    //register btn, NOTE: NOT register action
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
    
    //email login, NOTE: NOT email login action
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
    
    //email login action
    func didTapLoginAction() {
        if let inputtedEmail = loginView.emailTextField.text, let inputtedPw = loginView.pwTextField.text {
            loginView.loginActionBtn.isUserInteractionEnabled = false
            
            //hide button title
            UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.loginView.loginActionBtn.setTitle("", for: .normal)
            }, completion: nil)
            
            //show indicator
            UIView.animate(withDuration: 0.2) {
                self.loginView.loginActivityIndicator.startAnimating()
                self.loginView.loginActivityIndicator.alpha = 1
            }
            
            //validation
            let emailValidateResult = inputtedEmail.validate(rules: M7ValidationRule.emailRules())
            let pwValidateResult = inputtedPw.validate(rules: M7ValidationRule.pwRules())
            
            switch emailValidateResult {
            case .valid:
                switch pwValidateResult {
                case .valid:
                    //login action
                    UserService.Email.login(email: inputtedEmail, password: inputtedPw, loginView: loginView)
                    
                case .invalid(let failures):
                    //hide indicator
                    UIView.animate(withDuration: 0.2) {
                        self.loginView.loginActivityIndicator.alpha = 0
                        self.loginView.loginActivityIndicator.stopAnimating()
                    }
                    
                    loginView.pwTextFieldBg.shake()
                    HapticFeedback.createNotificationFeedback(style: .error)
                    
                    //animate title change to error msg
                    let messages = failures.compactMap { $0 as? ValidationError }.map { $0.message }
                    UIView.transition(with: self.loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.loginActionBtn.setTitle("Password \(messages.joined(separator: " and "))!", for: .normal)
                        self.loginView.loginActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                    }, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        UIView.transition(with: self.loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.loginView.loginActionBtn.setTitle("登入", for: .normal)
                            self.loginView.loginActionBtn.setTitleColor(.whiteText(), for: .normal)
                        }, completion: nil)
                        self.loginView.loginActionBtn.isUserInteractionEnabled = true
                    }
                }
                
            case .invalid(let failures):
                //hide indicator
                UIView.animate(withDuration: 0.2) {
                    self.loginView.loginActivityIndicator.alpha = 0
                    self.loginView.loginActivityIndicator.stopAnimating()
                }
                
                loginView.emailTextFieldBg.shake()
                HapticFeedback.createNotificationFeedback(style: .error)
                
                //animate title change to error msg
                let messages = failures.compactMap { $0 as? ValidationError }.map { $0.message }
                UIView.transition(with: self.loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.loginActionBtn.setTitle("Email is \(messages.joined(separator: " and "))!", for: .normal)
                    self.loginView.loginActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                }, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    UIView.transition(with: self.loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.loginActionBtn.setTitle("登入", for: .normal)
                        self.loginView.loginActionBtn.setTitleColor(.whiteText(), for: .normal)
                    }, completion: nil)
                    self.loginView.loginActionBtn.isUserInteractionEnabled = true
                }
            }

        }
    }
    
    //register action
    func didTapRegAction() {
        if let inputtedEmail = loginView.regEmailTextField.text, let inputtedPw = loginView.regPwTextField.text, let inputtedPwRefill = loginView.regPwRefillTextField.text {
            loginView.regActionBtn.isUserInteractionEnabled = false
            
            //hide button title
            UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.loginView.regActionBtn.setTitle("", for: .normal)
            }, completion: nil)
            
            //show indicator
            UIView.animate(withDuration: 0.2) {
                self.loginView.regActivityIndicator.startAnimating()
                self.loginView.regActivityIndicator.alpha = 1
            }
            
            //validation
            let emailValidateResult = inputtedEmail.validate(rules: M7ValidationRule.emailRules())
            let pwValidateResult = inputtedPw.validate(rules: M7ValidationRule.pwRules())
            let pwRefillValidateResult = inputtedPwRefill.validate(rule: M7ValidationRule.pwCompareRule(pw: inputtedPw))
            
            switch emailValidateResult {
            case .valid:
                switch pwValidateResult {
                case .valid:
                    switch pwRefillValidateResult{
                    case .valid:
                        //register action
                        UserService.Email.register(email: inputtedEmail, password: inputtedPwRefill, loginView: loginView)
                        
                    case .invalid(let failures):
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            self.loginView.regActivityIndicator.alpha = 0
                            self.loginView.regActivityIndicator.stopAnimating()
                        }
                        
                        loginView.regPwRefillTextFieldBg.shake()
                        HapticFeedback.createNotificationFeedback(style: .error)
                        
                        //animate title change to error msg
                        let messages = failures.compactMap { $0 as? ValidationError }.map { $0.message }
                        UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.loginView.regActionBtn.setTitle("Passwords \(messages.joined(separator: " and "))!", for: .normal)
                            self.loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                            UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                self.loginView.regActionBtn.setTitle("註冊", for: .normal)
                                self.loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                            }, completion: nil)
                            self.loginView.regActionBtn.isUserInteractionEnabled = true
                        }
                    }
                    
                case .invalid(let failures):
                    //hide indicator
                    UIView.animate(withDuration: 0.2) {
                        self.loginView.regActivityIndicator.alpha = 0
                        self.loginView.regActivityIndicator.stopAnimating()
                    }
                    
                    loginView.regPwTextFieldBg.shake()
                    HapticFeedback.createNotificationFeedback(style: .error)
                    
                    //animate title change to error msg
                    let messages = failures.compactMap { $0 as? ValidationError }.map { $0.message }
                    UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.regActionBtn.setTitle("Password \(messages.joined(separator: " and "))!", for: .normal)
                        self.loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                    }, completion: nil)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                        UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.loginView.regActionBtn.setTitle("註冊", for: .normal)
                            self.loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                        }, completion: nil)
                        self.loginView.regActionBtn.isUserInteractionEnabled = true
                    }
                }
                
            case .invalid(let failures):
                //hide indicator
                UIView.animate(withDuration: 0.2) {
                    self.loginView.regActivityIndicator.alpha = 0
                    self.loginView.regActivityIndicator.stopAnimating()
                }
                
                loginView.regEmailTextFieldBg.shake()
                HapticFeedback.createNotificationFeedback(style: .error)
                
                //animate title change to error msg
                let messages = failures.compactMap { $0 as? ValidationError }.map { $0.message }
                UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.loginView.regActionBtn.setTitle("Email is \(messages.joined(separator: " and "))!", for: .normal)
                    self.loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                }, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                    UIView.transition(with: self.loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.loginView.regActionBtn.setTitle("註冊", for: .normal)
                        self.loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                    }, completion: nil)
                    self.loginView.regActionBtn.isUserInteractionEnabled = true
                }
            }

        }
    }
    
}

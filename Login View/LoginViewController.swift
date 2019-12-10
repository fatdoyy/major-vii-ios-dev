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
import AuthenticationServices
import JGProgressHUD

class LoginViewController: UIViewController {
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    var identityToken: String? //Apple sign in identityToken
    
    @IBOutlet weak var loginView: LoginView!
    var hud = JGProgressHUD(style: .dark)
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginView.delegate = self
        updatesStatusBarAppearanceAutomatically = true
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.type != .iPhone_5_5S_5C_SE { // not loading GIFs on iPhone SE becasue of performance issue
            loadGIF()
        }
        
        NotificationCenter.default.setObserver(self, selector: #selector(dismissLoginVC), name: .dismissLoginVC, object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if !self.isModal { //send notification to refresh EventListViewController
            if UserService.current.isLoggedIn() {
                NotificationCenter.default.post(name: .refreshEventListVC, object: nil)
                NotificationCenter.default.removeObserver(loginView!) // also remove observer in LoginView.swift
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
                if #available(iOS 13.0, *) { //call delegate method manually for iOS 13 modal views
                    if let pvc = self.presentationController {
                        pvc.delegate?.presentationControllerWillDismiss?(pvc)
                    }
                }
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}

//MARK: - Login / Register Delegate
extension LoginViewController: LoginViewDelegate, UserServiceDelegate {
    func didTapDismissBtn() {
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
    
    //Google login (Disabled)
    func didTapGoogleLogin() {
//        userService.delegate = self
//        UserService.Google.logIn(fromVC: self)
    }
    
    func googleLoginPresent(_ viewController: UIViewController) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func googleLoginDismiss(_ viewController: UIViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func googleLoginWillDispatch() {}
    
    //Apple sign in
    func didTapAppleSignIn() {
        if #available(iOS 13.0, *) {
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
    
    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
    func performExistingAccountSetupFlows() {
        if #available(iOS 13.0, *) {
            // Prepare requests for both Apple ID and password providers.
            let req1 = ASAuthorizationAppleIDProvider().createRequest()
            req1.requestedScopes = [.fullName, .email]
            
            let requests = [req1, ASAuthorizationPasswordProvider().createRequest()]
            
            // Create an authorization controller with the given requests.
            let authorizationController = ASAuthorizationController(authorizationRequests: requests)
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    //register btn, NOTE: NOT register action
    func didTapRegisterBtn() {
        //hide social login elements
        if #available(iOS 13.0, *) {
            if let appleSignInBtn = loginView.appleSignInBtn as! ASAuthorizationAppleIDButton? {
                UIView.animate(withDuration: 0.2) {
                    appleSignInBtn.alpha = 0
                }
                appleSignInBtn.isUserInteractionEnabled = false
            }
        }
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
            if #available(iOS 13.0, *) {
                if let appleSignInBtn = loginView.appleSignInBtn as! ASAuthorizationAppleIDButton? {
                    UIView.animate(withDuration: 0.2) {
                        appleSignInBtn.alpha = 0
                    }
                    appleSignInBtn.isUserInteractionEnabled = false
                }
            }
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
            if #available(iOS 13.0, *) {
                if let appleSignInBtn = loginView.appleSignInBtn as! ASAuthorizationAppleIDButton? {
                    UIView.animate(withDuration: 0.2) {
                        appleSignInBtn.alpha = 1
                    }
                    appleSignInBtn.isUserInteractionEnabled = true
                }
            }
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
                    let messages = failures.compactMap { $0 as? MyValidationError }.map { $0.message }
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
                let messages = failures.compactMap { $0 as? MyValidationError }.map { $0.message }
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
    
    //email register action
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
                        let messages = failures.compactMap { $0 as? MyValidationError }.map { $0.message }
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
                    let messages = failures.compactMap { $0 as? MyValidationError }.map { $0.message }
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
                let messages = failures.compactMap { $0 as? MyValidationError }.map { $0.message }
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

//MARK: - Apple Sign in delegate
extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let userID = appleIDCredential.user
            //refresh expired tokens
            if let newIdentityToken = appleIDCredential.identityToken, let newAuthCode = appleIDCredential.authorizationCode {
                let identityTokenStr = String(data: newIdentityToken, encoding: .utf8) ?? ""
                let authCodeStr = String(data: newAuthCode, encoding: .utf8) ?? ""
                
                //check existing identity token
                if UserDefaults.standard.hasValue(LOCAL_KEY.APPLE_IDENTITY_TOKEN) {
                    print("refreshing token")
                    if UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_IDENTITY_TOKEN) != identityTokenStr {
                        UserDefaults.standard.set(identityTokenStr, forKey: LOCAL_KEY.APPLE_IDENTITY_TOKEN)
                        self.identityToken = identityTokenStr
                        print("identityToken = \(identityTokenStr)")
                    }
                }
                
                //check existing auth code
                if UserDefaults.standard.hasValue(LOCAL_KEY.APPLE_AUTH_CODE) {
                    print("refreshing auth code")
                    if UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_AUTH_CODE) != authCodeStr {
                        UserDefaults.standard.set(authCodeStr, forKey: LOCAL_KEY.APPLE_AUTH_CODE)
                        print("authCodeStr = \(authCodeStr)")
                    }
                }
            }
            
            //first time apple sign in
            if let identityToken = appleIDCredential.identityToken, let authCode = appleIDCredential.authorizationCode, let userName = appleIDCredential.fullName?.givenName, let email = appleIDCredential.email {
                print("Successfully got data from Apple, proceeding to request JWT...")
                showHud()
                
                //save apple credentials to local, NOTICE: store all as String type
                UserDefaults.standard.set(userID, forKey: LOCAL_KEY.APPLE_USER_ID)
                UserDefaults.standard.set(String(data: identityToken, encoding: .utf8) ?? "", forKey: LOCAL_KEY.APPLE_IDENTITY_TOKEN)
                UserDefaults.standard.set(String(data: authCode, encoding: .utf8) ?? "", forKey: LOCAL_KEY.APPLE_AUTH_CODE)
                UserDefaults.standard.set(userName, forKey: LOCAL_KEY.APPLE_USERNAME)
                UserDefaults.standard.set(email, forKey: LOCAL_KEY.APPLE_EMAIL)
                
                //m7 login
                UserService.Apple.login(identityToken: String(data: identityToken, encoding: .utf8) ?? "", authCode: String(data: authCode, encoding: .utf8) ?? "", userID: userID, email: email, userName: userName, fromVC: self)
            }

            // Create an account in your system.
            // store the userIdentifier in the keychain.
//            do {
//                try KeychainItem(service: "app.major7.ios", account: "userIdentifier").saveItem(userIdentifier)
//            } catch {
//                print("Unable to save userIdentifier to keychain.")
//            }
            //print("state: \(appleIDCredential.state)")
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            print("\(username), \(password)")
        }
        
        //Temp fix for re-login
        if !UserService.current.isLoggedIn() {
            print("re-login using Apple...")
            if
                let userID = UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_USER_ID),
                let identityToken = UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_IDENTITY_TOKEN),
                let authCode = UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_AUTH_CODE),
                let userName = UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_USERNAME),
                let email = UserDefaults.standard.string(forKey: LOCAL_KEY.APPLE_EMAIL) {
                
                //print("userID = \(userID)\nidentityToken = \(identityToken)\nauthCode = \(authCode)\nuserName = \(userName)\nemail = \(email)")
                showHud()
                UserService.Apple.login(identityToken: identityToken, authCode: authCode, userID: userID, email: email, userName: userName, fromVC: self)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func showHud() {
        //show hud
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.textLabel.text = "Working hard..."
        hud.detailTextLabel.text = "eating Apple (づ￣ ³￣)づ"
        hud.layoutMargins = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        hud.show(in: self.view)
    }
}

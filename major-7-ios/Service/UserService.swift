//
//  UserService.swift
//  major-7-ios
//
//  Created by jason on 4/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import FacebookCore
import FacebookLogin
import GoogleSignIn
import PromiseKit
import JGProgressHUD

protocol UserServiceDelegate {
    func googleLoginPresent(_ viewController: UIViewController)
    func googleLoginDismiss(_ viewController: UIViewController)
    func googleLoginWillDispatch()
}

class UserService: NSObject {
    
    static var sharedInstance = UserService()
    
    var delegate: UserServiceDelegate?
    
    static var hud = JGProgressHUD(style: .light)
    
    override init() {
        super.init()
        UserService.hud.vibrancyEnabled = true
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    class func isUserLoggedIn() -> Bool {
        if AccessToken.current == nil || GIDSignIn.sharedInstance()?.hasAuthInKeychain() == false {
            return false
        } else {
            return true
        }
    }
    
}

//facebook login
extension UserService {
    struct FB{
        static func login(fromVC: UIViewController){
            
            let loginManager = LoginManager()
            
            loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: fromVC) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in - \(accessToken.authenticationToken)")
                    print("grantedPermissions - \(grantedPermissions)")
                    print("declinedPermissions - \(declinedPermissions)")
                    
                    //show hud
                    hud.textLabel.text = "Working Hard..."
                    hud.detailTextLabel.text = "Calling to Facebook... (☞ﾟ∀ﾟ)☞"
                    hud.layoutMargins = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
                    hud.show(in: fromVC.view)
                    
                    getFbUserInfo(accessToken: accessToken, vc: fromVC, hud: hud)
                }
            }
        }
        
        static func getFbUserInfo(accessToken: AccessToken, vc: UIViewController, hud: JGProgressHUD){
            let graphRequest: GraphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "first_name, email, picture.type(large)"], accessToken: accessToken, httpMethod: .GET)
            graphRequest.start({ (response, result) in
                switch result {
                case .failed(let error):
                    print(error)
                case .success(let result):
                    if let dict = result.dictionaryValue {
                        
                        let userId  = dict["id"] as! String
                        let email   = dict["email"] as! String
                        let name    = dict["first_name"] as! String
                        
                        //After getting user details on FB, register/login to Major VII
                        loginRequest(token: accessToken.authenticationToken, userId: userId, email: email, name: name, dismissVC: vc).done { response in
                            print(response)
                            
                            UIView.animate(withDuration: 0.25, animations: {
                                hud.textLabel.text = "Hello \(name)! (ᵔᴥᵔ)"
                                hud.detailTextLabel.text = nil
                                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                            })
                            
                            }.ensure  {
                                hud.dismiss(afterDelay: 0.75)
                                HapticFeedback.createNotificationFeedback(style: .success)
                                NotificationCenter.default.post(name: .loginCompleted, object: nil)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }.catch { error in }
                    }
                }
            })
        }
        
        //Login to Major VII using facebook
        static func loginRequest(token: String, userId: String, email: String, name: String, dismissVC: UIViewController) -> Promise<Any> {
            var param: [String : Any] = [:]
            param["fbAccessToken"]  = token
            param["fbUserId"]       = userId
            param["fbEmail"]        = email
            param["fbName"]         = name
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.fbLogin), param: param).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
        
        //logout
        static func logOut(){
            LoginManager().logOut()
        }
        
    }
}

//google login
extension UserService: GIDSignInDelegate, GIDSignInUIDelegate {
    struct Google {
        static func login(fromVC: UIViewController) {
            
            GIDSignIn.sharedInstance().signIn()
            
            //hud.textLabel.text = "123..."
            hud.layoutMargins = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            hud.show(in: fromVC.view)
        }
    }
    
    //google login delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else { // Perform any operations on signed in user here.
            //let dimension = round(100 * UIScreen.main.scale)
            //let pic = user.profile.imageURL(withDimension: UInt(dimension))
            
            if let userId = user.userID, let token = user.authentication.idToken, let name = user.profile.givenName, let email = user.profile.email {
                
                print("userid = \(userId), token = \(token), name = \(name), email = \(email)")
                
                loginRequest(token: token, userId: userId, email: email, name: name).done { response in
                    print(response)
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        UserService.hud.textLabel.text = "Hello \(name)! (ᵔᴥᵔ)"
                        UserService.hud.detailTextLabel.text = nil
                        UserService.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    })
                    
                    }.ensure  {
                        UserService.hud.dismiss(afterDelay: 0.75)
                        HapticFeedback.createNotificationFeedback(style: .success)
                        NotificationCenter.default.post(name: .loginCompleted, object: nil)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
            }
        }
    }
    
    //Login to Major VII using google
    private func loginRequest(token: String, userId: String, email: String, name: String) -> Promise<Any> {
        var param: [String : Any] = [:]
        param["idToken"]    = token
        param["email"]      = email
        param["userId"]     = userId
        param["userName"]   = name
        
        return Promise { resolver in
            BaseService.request(method: .post, url: BaseService.getActionPath(.googleLogin), param: param).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        delegate?.googleLoginPresent(viewController)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        delegate?.googleLoginDismiss(viewController)
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        //UserService.hud.dismiss()
        UserService.hud.textLabel.text = "Googling... (づ￣ ³￣)づ"
        delegate?.googleLoginWillDispatch()
    }
    
}

//email login
extension UserService {
    struct Email {
        static func login(email: String, password: String, loginView: LoginView) {
            loginRequest(email: email, password: password).done { response in
                print(response)
                if let dict = response as? [String:Any] {
                    /* NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message") */
                    if dict["success"] != nil { //200 OK
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.loginActivityIndicator.alpha = 0
                            loginView.loginActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change
                        UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            loginView.loginActionBtn.setTitle("入已登！ (づ｡◕‿‿◕｡)づ", for: .normal)
                            loginView.loginActionBtn.setTitleColor(.whiteText50Alpha(), for: .normal)
                        }, completion: nil)
                        
                        HapticFeedback.createNotificationFeedback(style: .success)
                        NotificationCenter.default.post(name: .loginCompleted, object: nil)
                        
                    } else { //error
                        HapticFeedback.createNotificationFeedback(style: .error)
                        
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.loginActivityIndicator.alpha = 0
                            loginView.loginActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change to error msg
                        UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            if let errorDict = dict["error"] as? Dictionary<String, Any> {
                                if let errorMsg = errorDict["msg"] {
                                    loginView.loginActionBtn.setTitle("\(errorMsg)!", for: .normal)
                                }
                            } else {
                                loginView.loginActionBtn.setTitle("Unknown Error", for: .normal)
                            }
                            loginView.loginActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        //reset button state
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                loginView.loginActionBtn.setTitle("登入", for: .normal)
                                loginView.loginActionBtn.setTitleColor(.whiteText(), for: .normal)
                            }, completion: nil)
                            
                            loginView.loginActionBtn.isUserInteractionEnabled = true
                        }
                    }
                } else {
                    print("can't cast response to as [String:Any]")
                }
                }.ensure {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }.catch { error in }
        }
        
        static func register(email: String, password: String, loginView: LoginView) {
            registerRequest(email: email, password: password).done { response in
                print(response)
                if let dict = response as? [String:Any] {
                    /* NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message") */
                    if dict["success"] != nil { //200 OK
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.regActivityIndicator.alpha = 0
                            loginView.regActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change
                        UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            loginView.regActionBtn.setTitle("冊已註！ (づ｡◕‿‿◕｡)づ", for: .normal)
                            loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                    } else {
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.regActivityIndicator.alpha = 0
                            loginView.regActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change
                        UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            if let errorDict = dict["error"] as? Dictionary<String, Any> {
                                if let errorMsg = errorDict["msg"] {
                                    loginView.regActionBtn.setTitle("\(errorMsg)!", for: .normal)
                                }
                            } else {
                                loginView.regActionBtn.setTitle("Unknown Error", for: .normal)
                            }
                            loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                loginView.regActionBtn.setTitle("登入", for: .normal)
                                loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                            }, completion: nil)
                            loginView.regActionBtn.isUserInteractionEnabled = true
                        }
                    }
                } else {
                    print("can't cast response to as [String:Any]")
                }
                }.ensure {
                    NotificationCenter.default.post(name: .loginCompleted, object: nil)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }.catch { error in }
        }
        
        static func loginRequest(email: String, password: String) -> Promise<Any> {
            var param: [String : Any] = [:]
            param["email"]        = email
            param["password"]     = password
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.emailLogin), param: param).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
        
        static func registerRequest(email: String, password: String) -> Promise<Any> {
            var param: [String : Any] = [:]
            param["email"]        = email
            param["password"]     = password
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.emailReg), param: param).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
    }
}

extension Notification.Name {
    static let loginCompleted = Notification.Name("loginCompleted")
}

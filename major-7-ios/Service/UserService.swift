//
//  UserService.swift
//  major-7-ios
//
//  Created by jason on 4/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import PromiseKit
import ObjectMapper
import JGProgressHUD

protocol UserServiceDelegate: AnyObject {
    func googleLoginPresent(_ viewController: UIViewController)
    func googleLoginDismiss(_ viewController: UIViewController)
    func googleLoginWillDispatch()
}

class UserService: BaseService {
    static var sharedInstance = UserService()
    
    weak var delegate: UserServiceDelegate?

    static var hud = JGProgressHUD(style: .light)

    override init() {
        super.init()
        UserService.hud.vibrancyEnabled = true
        //GIDSignIn.sharedInstance.delegate = self
        //GIDSignIn.sharedInstance.uiDelegate = self
    }
    
    struct current {
        //check current user
        static func isLoggedIn() -> Bool {
            let notLoggedIn = hasUserId() == false || hasAccessToken() == false || hasRefreshToken() == false || hasUsername() == false
            return true != notLoggedIn
        }
        
        //logout
        static func logout(fromVC: UIViewController) -> Promise<Any> {
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.logout)).done { response in
                    resolver.fulfill(response)
                    }.ensure {
                        UserDefaults.standard.removeObject(forKey: LOCAL_KEY.USER_ID)
                        UserDefaults.standard.removeObject(forKey: LOCAL_KEY.ACCESS_TOKEN)
                        UserDefaults.standard.removeObject(forKey: LOCAL_KEY.REFRESH_TOKEN)
                        UserDefaults.standard.removeObject(forKey: LOCAL_KEY.USERNAME)
                        
                        //Optional?
                        //FB.logOut()
                        //Google.logOut()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
        
        //check if has user id/tokens
        static func hasUserId() -> Bool {
            return false != UserDefaults.standard.hasValue(LOCAL_KEY.USER_ID)
        }
        
        static func hasAccessToken() -> Bool {
            return false != UserDefaults.standard.hasValue(LOCAL_KEY.ACCESS_TOKEN)
        }
        
        static func hasRefreshToken() -> Bool {
            return false != UserDefaults.standard.hasValue(LOCAL_KEY.REFRESH_TOKEN)
        }
        
        static func hasUsername() -> Bool {
            return false != UserDefaults.standard.hasValue(LOCAL_KEY.USERNAME)
        }
    }

}

//MARK: - Facebook login
extension UserService {
    struct FB {
        static func logIn(fromVC: UIViewController) {
            let loginManager = LoginManager()
            
            loginManager.logIn(permissions: ["public_profile", "email"], from: fromVC) { (result, error) in
                // Check for error
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("User cancelled login")
                    return
                }
                
                // Successful
                if let token = result.token {
                    print("Logged in - \(token)")
                    print("grantedPermissions - \(result.grantedPermissions)")
                    print("declinedPermissions - \(result.declinedPermissions)")
                                        
                    //show hud
                    hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
                    hud.textLabel.text = "Working Hard..."
                    hud.detailTextLabel.text = "Calling to Facebook... (☞ﾟ∀ﾟ)☞"
                    hud.layoutMargins = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
                    hud.show(in: fromVC.view)
                    
                    getFbUserInfo(accessToken: token, vc: fromVC, hud: hud)
                }
            }
        }
        
        static func getFbUserInfo(accessToken: AccessToken, vc: UIViewController, hud: JGProgressHUD) {
            guard AccessToken.current != nil else { return }
            
            let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields": "first_name, email, picture.type(large)"], httpMethod: .get)
            graphRequest.start() { (connection, result, error) in
                // Check error
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                
                // Successful
                if let result = result {
                    if let response = result as? Dictionary<String, AnyObject> {
                        let userId  = response["id"] as! String
                        let email   = response["email"] as! String
                        let name    = response["first_name"] as! String
                        print("Successfully got data from Facebook, proceeding to request JWT...")
                     
                        //After getting user details on FB, register/login to Major VII
                        loginRequest(token: accessToken.tokenString, userId: userId, email: email, name: name, dismissVC: vc).done { response in
                            if let apiResponse = response as? [String: Any] {
                                print(apiResponse)
                                if apiResponse["success"] != nil { //200 OK
                                    /// NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message")
                                    print("Sucecssfully created MajorVII account")
                                    HapticFeedback.createNotificationFeedback(style: .success)

                                    //animate hud change
                                    UIView.animate(withDuration: 0.25, animations: {
                                        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                        hud.textLabel.text = "Hello \(name)! (ᵔᴥᵔ)"
                                        hud.detailTextLabel.text = nil
                                    })

                                    //save tokens/user id to local
                                    UserDefaults.standard.set(apiResponse["user_id"], forKey: LOCAL_KEY.USER_ID)
                                    UserDefaults.standard.set(apiResponse["access_token"], forKey: LOCAL_KEY.ACCESS_TOKEN)
                                    UserDefaults.standard.set(apiResponse["refresh_token"], forKey: LOCAL_KEY.REFRESH_TOKEN)
                                    UserDefaults.standard.set(name, forKey: LOCAL_KEY.USERNAME)

                                    //hide login view
                                    NotificationCenter.default.post(name: .dismissLoginVC, object: nil)
                                    hud.dismiss(afterDelay: 0.75)
                                } else { //api respond error
                                    HapticFeedback.createNotificationFeedback(style: .error)

                                    if let errorObj = apiResponse["error"] as? [String: Any] {
                                        if let errorMsg = errorObj["msg"] {
                                            UIView.animate(withDuration: 0.25, animations: {
                                                hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                                hud.textLabel.text = "Error: \(errorMsg)"
                                                hud.detailTextLabel.text = nil
                                            })
                                        }
                                    } else {
                                        UIView.animate(withDuration: 0.25, animations: {
                                            hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                            hud.textLabel.text = "Unknown Error"
                                            hud.detailTextLabel.text = nil
                                        })
                                    }
                                }
                                hud.dismiss(afterDelay: 2)
                            }
                        }.ensure  {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                    }
                }
                
                
                
                
                
                
                
            }
        }
        
        //Login to Major VII with facebook params
        static func loginRequest(token: String, userId: String, email: String, name: String, dismissVC: UIViewController) -> Promise<Any> {
            var params: [String: Any] = [:]
            params["fbAccessToken"]  = token
            params["fbUserId"]       = userId
            params["fbEmail"]        = email
            params["fbName"]         = name
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.fbLogin), params: params).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
        
        //FB logout, NOTE: NOT Major VII Logout
        static func logOut() {
            if AccessToken.current == nil {
                LoginManager().logOut()
            }
        }
        
    }
}

//MARK: - Google login (Disabled)
/*
extension UserService: GIDSignInDelegate/*, GIDSignInUIDelegate*/ {
    struct Google {
        static func logIn(fromVC: UIViewController) {
            
            GIDSignIn.sharedInstance.signIn()
            
            //hud.textLabel.text = "123..."
            hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
            hud.layoutMargins = UIEdgeInsets.init(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            hud.show(in: fromVC.view)
        }
        
        //Google logout, NOTE: NOT Major VII logout
        static func logOut() {
            //if GIDSignIn.sharedInstance?.hasAuthInKeychain() == true {
                GIDSignIn.sharedInstance?.signOut()
                GIDSignIn.sharedInstance?.disconnect()
            //}
        }
    }
    
    //google login delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else { // Perform any operations on Google signed in user here.
            //let dimension = round(100 * UIScreen.main.scale)
            //let pic = user.profile.imageURL(withDimension: UInt(dimension))
            
            if let userId = user.userID, let token = user.authentication.idToken, let name = user.profile?.givenName, let email = user.profile?.email {
                
                print("Successfully got data from Google\nuserid = \(userId)\ntoken = \(token)\nname = \(name)\nemail = \(email)\nProceeding to request JWT...")
                
                loginRequest(token: token, userId: userId, email: email, name: name).done { response in
                    if let apiResponse = response as? [String: Any] {
                        print(apiResponse)
                        if apiResponse["success"] != nil { //200 OK
                            ///NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message")
                            print("Sucecssfully created MajorVII account")
                            HapticFeedback.createNotificationFeedback(style: .success)

                            //animate hud change
                            UIView.animate(withDuration: 0.25, animations: {
                                UserService.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                UserService.hud.textLabel.text = "Hello \(name)! (ᵔᴥᵔ)"
                                UserService.hud.detailTextLabel.text = nil
                            })
                            
                            //save tokens/user id to local
                            UserDefaults.standard.set(apiResponse["user_id"], forKey: LOCAL_KEY.USER_ID)
                            UserDefaults.standard.set(apiResponse["access_token"], forKey: LOCAL_KEY.ACCESS_TOKEN)
                            UserDefaults.standard.set(apiResponse["refresh_token"], forKey: LOCAL_KEY.REFRESH_TOKEN)
                            UserDefaults.standard.set(name, forKey: LOCAL_KEY.USERNAME)
                            
                            //hide login view
                            NotificationCenter.default.post(name: .dismissLoginVC, object: nil)

                        } else { //api respond error
                            HapticFeedback.createNotificationFeedback(style: .error)
                            
                            if let errorObj = apiResponse["error"] as? [String: Any] {
                                if let errorMsg = errorObj["msg"] {
                                    UIView.animate(withDuration: 0.25, animations: {
                                        UserService.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                        UserService.hud.textLabel.text = "Error: \(errorMsg)"
                                        UserService.hud.detailTextLabel.text = nil
                                    })
                                }
                            } else {
                                UIView.animate(withDuration: 0.25, animations: {
                                    UserService.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                    UserService.hud.textLabel.text = "Unknown Error"
                                    UserService.hud.detailTextLabel.text = nil
                                })
                            }
                        }
                    }
                    }.ensure  {
                        UserService.hud.dismiss(afterDelay: 0.75)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
            }
        }
    }
    
    //Login to Major VII (get token from major vii)
    private func loginRequest(token: String, userId: String, email: String, name: String) -> Promise<Any> {
        var params: [String: Any] = [:]
        params["idToken"]    = token
        params["email"]      = email
        params["userId"]     = userId
        params["userName"]   = name
        
        return Promise { resolver in
            BaseService.request(method: .post, url: BaseService.getActionPath(.googleLogin), params: params).done { response in
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
*/
//MARK: - Apple Sign in
extension UserService {
    struct Apple {
        static func login(identityToken: String, authCode: String, userID: String, email: String, userName: String, fromVC: LoginViewController) {
            loginRequest(identityToken: identityToken, authCode: authCode, userID: userID, email: email, userName: userName).done { response in
                if let apiResponse = response as? [String: Any] {
                    print(apiResponse)
                    if apiResponse["success"] != nil { //200 OK
                        /// NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message")
                        print("Sucecssfully created MajorVII account")
                        HapticFeedback.createNotificationFeedback(style: .success)
                        
                        //animate hud change
                        UIView.animate(withDuration: 0.25, animations: {
                            fromVC.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                            fromVC.hud.textLabel.text = "Hello \(userName)! (ᵔᴥᵔ)"
                            fromVC.hud.detailTextLabel.text = nil
                        })
                        
                        //save m7 credentials to local
                        UserDefaults.standard.set(apiResponse["user_id"], forKey: LOCAL_KEY.USER_ID)
                        UserDefaults.standard.set(apiResponse["access_token"], forKey: LOCAL_KEY.ACCESS_TOKEN)
                        UserDefaults.standard.set(apiResponse["refresh_token"], forKey: LOCAL_KEY.REFRESH_TOKEN)
                        UserDefaults.standard.set(userName, forKey: LOCAL_KEY.USERNAME)
                        
                        //hide login view
                        NotificationCenter.default.post(name: .dismissLoginVC, object: nil)
                        
                    } else { //api respond error
                        HapticFeedback.createNotificationFeedback(style: .error)

                        if let errorObj = apiResponse["error"] as? [String: Any] {
                            if let errorMsg = errorObj["msg"] {
                                UIView.animate(withDuration: 0.25, animations: {
                                    fromVC.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                    fromVC.hud.textLabel.text = "Error: \(errorMsg)"
                                    fromVC.hud.detailTextLabel.text = nil
                                })
                            }
                        } else {
                            UIView.animate(withDuration: 0.25, animations: {
                                fromVC.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                                fromVC.hud.textLabel.text = "Unknown Error"
                                fromVC.hud.detailTextLabel.text = nil
                            })
                        }
                    }
                }
            }.ensure {
                fromVC.hud.dismiss(afterDelay: 0.75)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
        }
    }
    
    //send params to MajorVII API and get response
    static func loginRequest(identityToken: String, authCode: String, userID: String, email: String, userName: String) -> Promise<Any> {
        var params: [String: Any] = [:]
        params["identityToken"] = identityToken
        params["authCode"]      = authCode
        params["userId"]        = userID
        params["email"]         = email
        params["userName"]      = userName
        
        return Promise { resolver in
            BaseService.request(method: .post, url: BaseService.getActionPath(.appleSignIn), params: params).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
}

//MARK: - Email login / register
extension UserService {
    struct Email {
        static func login(email: String, password: String, loginView: LoginView) {
            loginRequest(email: email, password: password).done { response in
                print(response)
                if let apiResponse = response as? [String: Any] {
                    if apiResponse["success"] != nil { //200 OK
                        ///NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message")
                        print("Sucecssfully logged in MajorVII account")
                        HapticFeedback.createNotificationFeedback(style: .success)
                        
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.loginActivityIndicator.alpha = 0
                            loginView.loginActivityIndicator.stopAnimating()
                        }
                        
                        //save tokens/user id to local
                        UserDefaults.standard.set(apiResponse["user_id"], forKey: LOCAL_KEY.USER_ID)
                        UserDefaults.standard.set(apiResponse["access_token"], forKey: LOCAL_KEY.ACCESS_TOKEN)
                        UserDefaults.standard.set(apiResponse["refresh_token"], forKey: LOCAL_KEY.REFRESH_TOKEN)
                        UserDefaults.standard.set(email.components(separatedBy: "@").first, forKey: LOCAL_KEY.USERNAME)
                        
                        //animate title change
                        UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            loginView.loginActionBtn.setTitle("入已登！ (づ｡◕‿‿◕｡)づ", for: .normal)
                            loginView.loginActionBtn.setTitleColor(.whiteText50Alpha(), for: .normal)
                        }, completion: nil)
                        
                        //hide login view
                        NotificationCenter.default.post(name: .dismissLoginVC, object: nil)
                        
                    } else { //api respond error
                        HapticFeedback.createNotificationFeedback(style: .error)
                        loginView.loginActionBtn.shake()
                        
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.loginActivityIndicator.alpha = 0
                            loginView.loginActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change to error msg
                        UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            if let errorObj = apiResponse["error"] as? [String: Any] {
                                if let errorMsg = errorObj["msg"] {
                                    loginView.loginActionBtn.setTitle("\(errorMsg)", for: .normal)
                                }
                            } else {
                                loginView.loginActionBtn.setTitle("Unknown Error", for: .normal)
                            }
                            loginView.loginActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        //reset button state
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            UIView.transition(with: loginView.loginActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                loginView.loginActionBtn.setTitle("登入", for: .normal)
                                loginView.loginActionBtn.setTitleColor(.whiteText(), for: .normal)
                            }, completion: nil)
                            loginView.loginActionBtn.isUserInteractionEnabled = true
                        }
                    }
                } else {
                    print("can't cast response to as [String: Any]")
                }
                }.ensure {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }.catch { error in }
        }
        
        static func register(email: String, password: String, loginView: LoginView) {
            registerRequest(email: email, password: password).done { response in
                print(response)
                if let apiResponse = response as? [String: Any] {
                    if apiResponse["success"] != nil { //200 OK
                        ///NOTE: We can't get the response's HTTPStatusCode here because of the way we handle http request (Alamofire + PromiseKit), by the way here the response must be 200 OK from Alamofire, so we need to check the content(key) of the response (i.e. success = 1; error: "message")
                        print("Sucecssfully created MajorVII account")
                        HapticFeedback.createNotificationFeedback(style: .success)
                        
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.regActivityIndicator.alpha = 0
                            loginView.regActivityIndicator.stopAnimating()
                        }
                        
                        //save tokens/user id to local
                        UserDefaults.standard.set(apiResponse["user_id"], forKey: LOCAL_KEY.USER_ID)
                        UserDefaults.standard.set(apiResponse["access_token"], forKey: LOCAL_KEY.ACCESS_TOKEN)
                        UserDefaults.standard.set(apiResponse["refresh_token"], forKey: LOCAL_KEY.REFRESH_TOKEN)
                        UserDefaults.standard.set(email.components(separatedBy: "@").first, forKey: LOCAL_KEY.USERNAME)

                        //animate title change
                        UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            loginView.regActionBtn.setTitle("冊已註！ (づ｡◕‿‿◕｡)づ", for: .normal)
                            loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        //hide login view
                        NotificationCenter.default.post(name: .dismissLoginVC, object: nil)

                    } else {
                        HapticFeedback.createNotificationFeedback(style: .error)
                        loginView.regActionBtn.shake()
                        
                        //hide indicator
                        UIView.animate(withDuration: 0.2) {
                            loginView.regActivityIndicator.alpha = 0
                            loginView.regActivityIndicator.stopAnimating()
                        }
                        
                        //animate title change
                        UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            if let errorObj = apiResponse["error"] as? [String: Any] {
                                if let errorMsg = errorObj["msg"] {
                                    loginView.regActionBtn.setTitle("\(errorMsg)!", for: .normal)
                                }
                            } else {
                                loginView.regActionBtn.setTitle("Unknown Error", for: .normal)
                            }
                            loginView.regActionBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
                        }, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            UIView.transition(with: loginView.regActionBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                loginView.regActionBtn.setTitle("註冊", for: .normal)
                                loginView.regActionBtn.setTitleColor(.whiteText(), for: .normal)
                            }, completion: nil)
                            loginView.regActionBtn.isUserInteractionEnabled = true
                        }
                    }
                } else {
                    print("can't cast response to as [String: Any]")
                }
                }.ensure {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }.catch { error in }
        }
        
        static func loginRequest(email: String, password: String) -> Promise<Any> {
            var params: [String: Any] = [:]
            
            params["email"]        = email
            params["password"]     = password
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.emailLogin), params: params).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
        
        static func registerRequest(email: String, password: String) -> Promise<Any> {
            var params: [String: Any] = [:]
            
            params["email"]        = email
            params["password"]     = password
            
            return Promise { resolver in
                BaseService.request(method: .post, url: BaseService.getActionPath(.emailRegister), params: params).done { response in
                    resolver.fulfill(response)
                    }.catch { error in
                        resolver.reject(error)
                }
            }
        }
    }
}

//MARK: - Other functions
extension UserService {
    //get user followings
    static func getUserFollowings(skip: Int? = nil, limit: Int? = nil, targetProfile: OrganizerProfile? = nil, targetType: Int? = nil) -> Promise<UserFollowings> {
        var params: [String: Any] = [:]
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        if let targetProfile = targetProfile {
            params["target_profile"] = targetProfile
        }
        
        if let targetType = targetType {
            params["target_type"] = targetType
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getCurrentUserFollowings), params: params).done { response in
                guard let list = Mapper<UserFollowings>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(list)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //get bookmarked events
    static func getBookmarkedEvents() -> Promise<BookmarkedEvents> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getCurrentUserBookmarkedEvents)).done { response in
                guard let events = Mapper<BookmarkedEvents>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
}


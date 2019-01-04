//
//  UserService.swift
//  major-7-ios
//
//  Created by jason on 4/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import FacebookCore
import FacebookLogin
import PromiseKit

class UserService : NSObject {
    
    //facebook login
    struct FB{
        static func login(fromVc: UIViewController){
            let loginManager = LoginManager()
            
            loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: fromVc) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print(error)
                case .cancelled:
                    print("User cancelled login.")
                case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                    print("Logged in - \(accessToken.authenticationToken)")
                    print("grantedPermissions - \(grantedPermissions)")
                    print("declinedPermissions - \(declinedPermissions)")
                    
                    getFbUserInfo(accessToken: accessToken, vc: fromVc)
                }
            }
        }
        
        static func getFbUserInfo(accessToken: AccessToken, vc: UIViewController){
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
                        m7Login(token: accessToken.authenticationToken, userId: userId, email: email, name: name, dismissVc: vc).done { response in
                            //print(response)
                            //do work...
                            
                            }.ensure  {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }.catch { error in }
                        
                    }
                    
                }
            })
        }
        
        //Login to Major VII
        static func m7Login(token: String, userId: String, email: String, name: String, dismissVc: UIViewController) -> Promise<Any> {
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
        
        static func logOut(){
            LoginManager().logOut()
        }
        
    }
    
    //google login
    struct Google {
        static func login(){
            
        }
    }
    
    
    static func isUserLoggedIn() -> Bool {
        //facebook
        if AccessToken.current == nil {
            return false
        } else {
            return true
        }
    }
    
    
    
}



//
//  BaseService.swift
//  major-7-ios
//
//  Created by jason on 29/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import Reqres

class BaseService: NSObject {

    static let endpoint = "http://major7-api-dev.herokuapp.com/"

    static func getActionPath(_ actionPath: ActionPath) -> String {
        var actionPathStr = ""
        switch actionPath {
            
        //Login | Register
        case .fbLogin:
            actionPathStr = "auth/login/facebook"
        case .googleLogin:
            actionPathStr = "auth/login/google"
        case .emailLogin:
            actionPathStr = "auth/login/email"
        case .emailReg:
            actionPathStr = "users/register/email"
            
            
        //News
        case .getNews:
            actionPathStr = "news"
            
        //Events
        case .getUpcomingEvents:
            actionPathStr = "events/upcoming"
        case .getTrendingEvents:
            actionPathStr = "events/mostPopular"
        case .getFollowingEvents:
            actionPathStr = "events/userFollowing"
        case .getFeaturedEvents:
            actionPathStr = "events/feature"
        case .getEventDetails(let eventId):
            actionPathStr = "events/\(eventId)"
            
        }
        return endpoint + actionPathStr
    }
    
    static private var manager : Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        //let configuration = Reqres.defaultSessionConfiguration()
        
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        
        return sessionManager
    }()
    
    static private func sharedHeaders() -> [String: String] {
        var headers = [
            "Content-Type": "application/x-www-form-urlencoded",
        ]
        
        if let userId = UserDefaults.standard.string(forKey: LOCAL_KEY.USER_ID) {
            headers["user-id"] = userId
        }
        
        if let accessToken = UserDefaults.standard.string(forKey: LOCAL_KEY.ACCESS_TOKEN) {
            headers["x-access-token"] = accessToken
        }
        
        if let refreshToken = UserDefaults.standard.string(forKey: LOCAL_KEY.REFRESH_TOKEN) {
            headers["x-refresh-token"] = refreshToken
        }
        
        return headers
    }
    
    static func request(method: Alamofire.HTTPMethod, url: String, params: [String: Any]? = nil) -> Promise<Any> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Promise { resolver in
            manager.request(url, method: method, parameters: params, encoding: URLEncoding.httpBody, headers: sharedHeaders()).responseJSON { response in
                switch response.result {
                case .success(let value):
                    resolver.fulfill(value)
                case .failure(let error):
                    resolver.reject(error)
                }
            }
        }
    }
}

extension BaseService {
    enum ActionPath{
        
        //Login | Register
        case fbLogin
        case googleLogin
        case emailLogin
        case emailReg
        
        //News
        case getNews
        
        //Events
        case getUpcomingEvents
        case getTrendingEvents
        case getFollowingEvents
        case getFeaturedEvents
        case getEventDetails(eventId: String)
        
    }
}

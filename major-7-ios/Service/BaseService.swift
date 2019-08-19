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

    static let endpoint = "https://major7-api-dev.herokuapp.com/"

    static func getActionPath(_ actionPath: ActionPath) -> String {
        var actionPathStr = ""
        switch actionPath {
            
        //Auth
        case .fbLogin:
            actionPathStr = "auth/login/facebook"
        case .googleLogin:
            actionPathStr = "auth/login/google"
        case .emailLogin:
            actionPathStr = "auth/login/email"
        case .logout:
            actionPathStr = "auth/logout"
        case .renewAcessToken:
            actionPathStr = "auth/renewAccessToken"
        case .resetPasswordEmail:
            actionPathStr = "auth/resetPasswordEmail"
        case .resetPasswordByToken:
            actionPathStr = "auth/resetPasswordByToken"
            
        //User
        case .currentUserInfo:
            actionPathStr = "users/me"
        case .getUserInfo(let userID):
            actionPathStr = "users/\(userID)"
        case .getCurrentUserSettings:
            actionPathStr = "users/me/settings"
        case .getCurrentUserFollowings:
            actionPathStr = "users/me/followings"
        case .getCurrentUserBookmarkedEvents:
            actionPathStr = "users/me/bookmarks"
        case .getCurrentUserBrowseHistory:
            actionPathStr = "users/me/browseHistory"
        case .postCurrentUserBrowseHistory(let objectType, let objectID):
            actionPathStr = "users/me/browseHistory/\(objectType)/\(objectID)"
        case .emailRegister:
            actionPathStr = "users/register/email"
        case .pushNotificationToken:
            actionPathStr = "users/pushNotificationToken"
        case .requestVerifyEmail:
            actionPathStr = "users/me/requestVerifyEmail"
        case .verifyEmail:
            actionPathStr = "users/verifyEmail"
        case .updatePassword:
            actionPathStr = "users/me/updatePassword"
            
            
        //Profile
        case .buskerRanking:
            actionPathStr = "profiles/trendRanking"
        case .buskerProfile(let buskerID):
            actionPathStr = "profiles/\(buskerID)"
        case .buskerEvents(let buskerID):
            actionPathStr = "profiles/\(buskerID)/events"
        case .buskerPosts(let buskerID):
            actionPathStr = "profiles/\(buskerID)/posts"
        case .buskerFollowers(let buskerID):
            actionPathStr = "profiles/\(buskerID)/followings"
            
        //News
        case .getNews:
            actionPathStr = "news"
        case .getNewsDetails(let newsID):
            actionPathStr = "news/\(newsID)"
            
        //Events
        case .getUpcomingEvents:
            actionPathStr = "events/upcoming"
        case .getTrendingEvents:
            actionPathStr = "events/mostPopular"
        case .getFollowingEvents:
            actionPathStr = "events/userFollowing"
        case .getFeaturedEvents:
            actionPathStr = "events/feature"
        case .getNearbyEvents:
            actionPathStr = "events/nearby"
        case .getEventDetails(let eventID):
            actionPathStr = "events/\(eventID)"
        case .bookmarkAction(let eventID):
            actionPathStr = "events/\(eventID)/bookmarks"
        case .eventReminders(let eventID):
            actionPathStr = "events/\(eventID)/reminders"
            
            
        //Posts
        case .getPosts:
            actionPathStr = "posts"
        case .getPostDetails(let postID):
            actionPathStr = "posts/\(postID)"
        case .commentAction(let postID):
            actionPathStr = "posts/\(postID)/comments"
        case .getPostsReactionSummary(let postID):
            actionPathStr = "posts/\(postID)/reactions/summary"
        case .postsReaction(let postID):
            actionPathStr = "posts/\(postID)/reactions"
            
        //Comment | Reactions
        case .commentDetails(let commentID):
            actionPathStr = "comments/\(commentID)"
        case .reactionDetails(let reactionID):
            actionPathStr = "reactions/\(reactionID)"
            
        //Search
        case .searchByPopularKeywords:
            actionPathStr = "search/popularKeywords"
        case .searchByBuskers:
            actionPathStr = "search/buskers"
        case .searchByEvents:
            actionPathStr = "search/events"
        case .searchByHashtags:
            actionPathStr = "search/hashtags"
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
        
        if let userID = UserDefaults.standard.string(forKey: LOCAL_KEY.USER_ID) {
            headers["user-id"] = userID
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
            manager.request(url, method: method, parameters: params, encoding: URLEncoding.methodDependent, headers: sharedHeaders()).responseJSON { response in
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
        
        //Auth
        case fbLogin
        case googleLogin
        case emailLogin
        case logout
        case renewAcessToken
        case resetPasswordEmail
        case resetPasswordByToken
        
        //User
        case currentUserInfo
        case getUserInfo(userID: String)
        case getCurrentUserSettings
        case getCurrentUserFollowings
        case getCurrentUserBookmarkedEvents
        case getCurrentUserBrowseHistory
        case postCurrentUserBrowseHistory(objectType: Int, objectID: String)
        case emailRegister
        case pushNotificationToken
        case requestVerifyEmail
        case verifyEmail
        case updatePassword
        
        //Busker
        case buskerRanking
        case buskerProfile(buskerID: String)
        case buskerEvents(buskerID: String)
        case buskerPosts(buskerID: String)
        case buskerFollowers(buskerID: String)
        
        //News
        case getNews
        case getNewsDetails(newsID: String)
        
        //Events
        case getUpcomingEvents
        case getTrendingEvents
        case getFollowingEvents
        case getFeaturedEvents
        case getNearbyEvents
        case getEventDetails(eventID: String)
        case bookmarkAction(eventID: String)
        case eventReminders(eventID: String)
        
        //Posts
        case getPosts
        case getPostDetails(postID: String)
        case commentAction(postID: String)
        case getPostsReactionSummary(postID: String)
        case postsReaction(postID: String)
        
        //Comment | Reactions
        case commentDetails(commentID: String)
        case reactionDetails(reactionID: String)
        
        //Search
        case searchByPopularKeywords
        case searchByBuskers
        case searchByEvents
        case searchByHashtags

    }
}

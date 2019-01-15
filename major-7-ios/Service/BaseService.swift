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
        let header = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        return header
    }
    
    static func request(method: Alamofire.HTTPMethod, url: String, param: [String: Any]? = nil) -> Promise<Any> {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return Promise { resolver in
            manager.request(url, method: method, parameters: param, encoding: URLEncoding.httpBody, headers: sharedHeaders()).responseJSON { response in
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

enum HTTPStatusCode: Int {
    // 100 Informational
    case `continue` = 100
    case switchingProtocols
    case processing
    // 200 Success
    case ok = 200
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case iMUsed = 226
    // 300 Redirection
    case multipleChoices = 300
    case movedPermanently
    case found
    case seeOther
    case notModified
    case useProxy
    case switchProxy
    case temporaryRedirect
    case permanentRedirect
    // 400 Client Error
    case badRequest = 400
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case proxyAuthenticationRequired
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case payloadTooLarge
    case uriTooLong
    case unsupportedMediaType
    case rangeNotSatisfiable
    case expectationFailed
    case imATeapot
    case misdirectedRequest = 421
    case unprocessableEntity
    case locked
    case failedDependency
    case upgradeRequired = 426
    case preconditionRequired = 428
    case tooManyRequests
    case requestHeaderFieldsTooLarge = 431
    case unavailableForLegalReasons = 451
    // 500 Server Error
    case internalServerError = 500
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case variantAlsoNegotiates
    case insufficientStorage
    case loopDetected
    case notExtended = 510
    case networkAuthenticationRequired
}

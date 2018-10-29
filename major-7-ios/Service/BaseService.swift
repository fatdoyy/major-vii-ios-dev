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

class BaseService: NSObject {

    static let endpoint = "http://major7-api-dev.herokuapp.com/"

    static func getActionPath(_ actionPath: ActionPath) -> String {
        var actionPathStr = ""
        switch actionPath {
        case .getNews:
            actionPathStr = "news"
            
        }
        return endpoint + actionPathStr
    }
    
    static private var manager : Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        
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
            manager.request(url, method: method, parameters: param, encoding: URLEncoding.httpBody, headers: sharedHeaders()).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    resolver.fulfill(value)
                case .failure(let error):
                    resolver.reject(error)
                }
            })
        }
    }
    
}

extension BaseService {
    enum ActionPath{
        
        case getNews
        
    }
}

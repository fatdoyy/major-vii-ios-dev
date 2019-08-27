//
//  PostService.swift
//  major-7-ios
//
//  Created by jason on 10/5/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import PromiseKit
import ObjectMapper

class PostService: BaseService {}

extension PostService {
    static func getList(skip: Int? = nil, limit: Int? = nil) -> Promise<Posts> {
        var params: [String: Any] = [:]
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getPosts), params: params).done { response in
                guard let news = Mapper<Posts>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(news)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
}

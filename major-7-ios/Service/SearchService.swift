//
//  SearchService.swift
//  major-7-ios
//
//  Created by jason on 19/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class SearchService: BaseService {}

extension SearchService {
    static func byKeywords() {} //TODO
    
    static func byBuskers(query: String, skip: Int? = nil, limit: Int? = nil) -> Promise<BuskersSearchResult> {
        var params: [String: Any] = [:]
        
        params["q"] = query
        
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.searchByBuskers), params: params).done { response in
                guard let results = Mapper<BuskersSearchResult>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(results)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    static func byEvents(query: String, skip: Int? = nil, limit: Int? = nil) -> Promise<EventsSearchResult> {
        var params: [String: Any] = [:]
        
        params["q"] = query
        
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.searchByEvents), params: params).done { response in
                guard let results = Mapper<EventsSearchResult>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(results)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
}

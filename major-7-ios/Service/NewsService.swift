//
//  NewsService.swift
//  major-7-ios
//
//  Created by jason on 29/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class NewsService: BaseService {}

extension NewsService {
    
    static func getList() -> Promise<NewsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getNews)).done { response in
                guard let news = Mapper<NewsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(news)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    static func getDetails(newsId: String) -> Promise<NewsDetails> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getNewsDetails(newsId: newsId))).done { response in
                guard let news = Mapper<NewsDetails>().map(JSONObject: response) else {
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

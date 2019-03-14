//
//  BuskerService.swift
//  major-7-ios
//
//  Created by jason on 14/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class BuskerService: BaseService {}

extension BuskerService {
    
    //busker profile details
    static func getProfileDetails(buskerId: String) -> Promise<BuskerProfile> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerProfile(buskerId: buskerId))).done { response in
                guard let upcomingEvent = Mapper<BuskerProfile>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(upcomingEvent)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker events
    static func getBuskerEvents(buskerId: String) -> Promise<BuskerEventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerEvents(buskerId: buskerId))).done { response in
                guard let upcomingEvent = Mapper<BuskerEventsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(upcomingEvent)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker posts
    static func getBuskerPosts(buskerId: String) -> Promise<BuskerPostsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerPosts(buskerId: buskerId))).done { response in
                guard let upcomingEvent = Mapper<BuskerPostsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(upcomingEvent)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
}

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
    static func getProfileDetails(buskerID: String) -> Promise<BuskerProfile> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerProfile(buskerID: buskerID))).done { response in
                guard let details = Mapper<BuskerProfile>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(details)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker events
    static func getBuskerEvents(buskerID: String) -> Promise<BuskerEventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerEvents(buskerID: buskerID))).done { response in
                guard let events = Mapper<BuskerEventsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker posts
    static func getBuskerPosts(buskerID: String) -> Promise<BuskerPostsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerPosts(buskerID: buskerID))).done { response in
                guard let posts = Mapper<BuskerPostsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(posts)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker profile follower list
    static func getBuskerFollowings(buskerID: String) -> Promise<BuskerPostsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.buskerFollowers(buskerID: buskerID))).done { response in
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
    
    //busker profile follow request
    static func followBusker(buskerID: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .post, url: getActionPath(.buskerFollowers(buskerID: buskerID))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //busker profile un-follow request
    static func unfollowBusker(buskerID: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .delete, url: getActionPath(.buskerFollowers(buskerID: buskerID))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
}

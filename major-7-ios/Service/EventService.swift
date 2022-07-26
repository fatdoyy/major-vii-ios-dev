//
//  EventService.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class EventService: BaseService {}

extension EventService {
    //upcoming events
    static func getUpcomingEvents() -> Promise<Events> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getUpcomingEvents)).done { response in
                guard let events = Mapper<Events>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //trending events
    static func getTrendingEvents() -> Promise<Events> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getTrendingEvents)).done { response in
                guard let events = Mapper<Events>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //following events
    static func getFollowingEvents(skip: Int? = nil, limit: Int? = nil) -> Promise<FollowingEvents> {
        var params: [String: Any] = [:]
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getFollowingEvents), params: params).done { response in
                guard let events = Mapper<FollowingEvents>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //featured events
    static func getFeaturedEvents(skip: Int? = nil, limit: Int? = nil) -> Promise<Events> {
        var params: [String: Any] = [:]
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getFeaturedEvents), params: params).done { response in
                guard let events = Mapper<Events>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(events)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //nearby events
    static func getNearbyEvents(lat: Double, long: Double, radius: Int? = nil, skip: Int? = nil, limit: Int? = nil) -> Promise<NearbyEvents> {
        var params: [String: Any] = [:]
        params["lat"] = lat
        params["lng"] = long
        
        if let radius = radius {
            params["radius"] = radius
        }
        
        if let skip = skip {
            params["skip"] = skip
        }
        
        if let limit = limit {
            params["limit"] = limit
        }
        
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getNearbyEvents), params: params).done { response in
                guard let nearbyEvents = Mapper<NearbyEvents>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(nearbyEvents)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    
    //event details
    static func getEventDetails(eventID: String) -> Promise<EventDetails> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getEventDetails(eventID: eventID))).done { response in
                guard let details = Mapper<EventDetails>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(details)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //create bookmark
    static func createBookmark(eventID: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .post, url: getActionPath(.bookmarkAction(eventID: eventID))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //remove bookmark
    static func removeBookmark(eventID: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .delete, url: getActionPath(.bookmarkAction(eventID: eventID))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
        
}

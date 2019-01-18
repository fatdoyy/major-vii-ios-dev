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
    static func getUpcomingEvents() -> Promise<EventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getUpcomingEvents)).done { response in
                guard let upcomingEvent = Mapper<EventsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(upcomingEvent)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //trending events
    static func getTrendingEvents() -> Promise<EventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getTrendingEvents)).done { response in
                guard let upcomingEvent = Mapper<EventsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(upcomingEvent)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //event details
    static func getEventDetails(eventId: String) -> Promise<EventDetails> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getEventDetails(eventId: eventId))).done { response in
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
    static func createBookmark(eventId: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .post, url: getActionPath(.bookmarkAction(eventId: eventId))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //remove bookmark
    static func removeBookmark(eventId: String) -> Promise<Any> {
        return Promise { resolver in
            request(method: .delete, url: getActionPath(.bookmarkAction(eventId: eventId))).done { response in
                resolver.fulfill(response)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    
    //get bookmarked events
    static func getBookmarkedEvents() -> Promise<BookmarkedEventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getBookmarkedEvents)).done { response in
                guard let details = Mapper<BookmarkedEventsList>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(details)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
    

    
}

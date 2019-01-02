//
//  EventsService.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class EventsService: BaseService {}

extension EventsService {
    
    //upcoming events
    static func fetchUpcomingEvents() -> Promise<EventsList> {
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
    
    //upcoming events
    static func fetchTrendingEvents() -> Promise<EventsList> {
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
    static func fetchEventDetails(eventId: String) -> Promise<EventDetails> {
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
    
    
}

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
    static func fetchUpcomingEvents() -> Promise<UpcomingEventsList> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.getUpcomingEvents)).done { response in
                guard let upcomingEvent = Mapper<UpcomingEventsList>().map(JSONObject: response) else {
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

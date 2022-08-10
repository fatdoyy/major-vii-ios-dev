//
//  Event.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class Event: Mappable {
    var hashtags = [String]()
    var images = [M7Image]()
    var id: String?
    var title: String?
    var organizerProfile: OrganizerProfile?
    var dateTime: String?
    var address: String?
    var location: EventLocation?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        hashtags            <- map["hashtags"]
        images              <- map["images"]
        id                  <- map["_id"]
        title               <- map["title"]
        organizerProfile    <- map["organizer_profile"]
        dateTime            <- map["datetime"]
        address             <- map["address"]
        location            <- map["location"]
    }
}

class Events: Mappable {
    var list = [Event]()
    
    init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list        <- map["list"]
    }
}

//MARK: Bookmarked events
class BookmarkedEvent: Mappable {
    var targetEvent: Event?
    var targetType: String?
    var createTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        targetEvent     <- map["target_event"]
        targetType      <- map["target_type"]
        createTime      <- map["create_time"]
    }
}

class BookmarkedEvents: Mappable {
    var list = [BookmarkedEvent]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list        <- map["list"]
    }
}

//MARK: Following events
class FollowingEvents: Mappable {
    var skip: Int?
    var limit: Int?
    var list = [Event]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        skip    <- map["skip"]
        limit   <- map["limit"]
        list    <- map["list"]
    }
}

//MARK: Nearby Events
class NearbyEvents: Mappable {
    var lat: CGFloat?
    var long: CGFloat?
    var radius: Int?
    var list = [NearbyEvent]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        lat     <- map["latitude"]
        long    <- map["longitude"]
        radius  <- map["radius"]
        list    <- map["list"]
    }
}

class EventLocation: Mappable {
    var coordinates = [Double]()
    var type: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        coordinates     <- map["coordinates"]
        type            <- map["type"]
    }
}

//class NearbyEvent: Event {
//    var distance: Double?
//
//    override func mapping(map: Map) {
//        distance    <- map["distance"]
//    }
//}

class NearbyEvent: Mappable {
    var hashtags = [String]()
    var images = [M7Image]()
    var id: String?
    var title: String?
    var organizerProfile: OrganizerProfile?
    var dateTime: String?
    var address: String?
    var location: EventLocation?
    var distance: Double?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        hashtags            <- map["hashtags"]
        images              <- map["images"]
        id                  <- map["_id"]
        title               <- map["title"]
        organizerProfile    <- map["organizer_profile"]
        dateTime            <- map["datetime"]
        address             <- map["address"]
        location            <- map["location"]
        distance            <- map["distance"]
    }
}

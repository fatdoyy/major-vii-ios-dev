//
//  Events.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class Events: Mappable {
    var list = [Event]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list        <- map["list"]
    }
}

class BookmarkedEvents: Mappable {
    var list = [BookmarkedEvent]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list        <- map["list"]
    }
}

class BookmarkedEvent: Mappable {
    var targetEvent: Event?
    var targetType: Int?
    var createTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        targetEvent     <- map["target_event"]
        targetType      <- map["target_type"]
        createTime      <- map["create_time"]
    }
}

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

class Event: Mappable {
    var hashtags = [String]()
    var images = [Image]()
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

class OrganizerProfile: Mappable {
    var musicTypes = [String]()
    var coverImages = [Image]()
    var id: String?
    var name: String?
    var type: Int?
    var verfied: Bool?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        musicTypes      <- map["music_types"]
        coverImages     <- map["cover_images"]
        id              <- map["_id"]
        name            <- map["name"]
        type            <- map["type"]
        verfied         <- map["verfied"]
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
    var images = [Image]()
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

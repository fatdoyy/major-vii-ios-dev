//
//  Events.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class UpcomingEventsList: Mappable {
    var list: [UpcomingEvents]?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list        <- map["list"]
    }
}

class UpcomingEvents: Mappable {
    var images = [Image]()
    var id: String?
    var title: String?
    var organizerProfile: OrganizerProfile?
    var dateTime: String?
    var address: String?
    var location: EventLocation?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        images              <- map["images"]
        id                  <- map["_id"]
        title               <- map["title"]
        organizerProfile   <- map["organizer_profile"]
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
    var coordinates = [Float]()
    var type: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        coordinates     <- map["coordinates"]
        type            <- map["type"]
    }
}

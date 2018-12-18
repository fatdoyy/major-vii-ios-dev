//
//  EventDetails.swift
//  major-7-ios
//
//  Created by jason on 18/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class EventDetails: Mappable {
    var requestUserIsAdmin: Bool?
    var item: DetailsItem?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        requestUserIsAdmin  <- map["request_user_is_admin"]
        item                <- map["item"]
    }
}

class DetailsItem: Mappable {
    var organizerProfile: OrganizerProfile?
    var title: String?
    var dateTime: String?
    var hashtags = [String]()
    var venue: String?
    var location: EventLocation?
    var desc: String?
    var images = [Image]()
    var remarks: String?
    var webUrl: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        organizerProfile    <- map["organizer_profile"]
        title               <- map["title"]
        dateTime            <- map["datetime"]
        hashtags            <- map["hashtags"]
        venue               <- map["address"]
        location            <- map["location"]
        desc                <- map["desc"]
        images              <- map["images"]
        remarks             <- map["remark"]
        webUrl              <- map["web_url"]
    }
    
    
}

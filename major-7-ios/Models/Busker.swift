//
//  Busker.swift
//  major-7-ios
//
//  Created by jason on 14/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class BuskerProfile: Mappable {
    var requestUserIsAdmin: Bool?
    var item: BuskerProfileDetails?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        requestUserIsAdmin  <- map["request_user_is_admin"]
        item                <- map["item"]
    }
}

class BuskerProfileDetails: Mappable {
    var type: Int?
    var name: String?
    var hashtags = [String]()
    var verified: Bool?
    var desc: String?
    var genres = [String]()
    var coverImages = [Image]()
    var members = [BuskerMember]()
    var igId: String?
    var fbId: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        type        <- map["type"]
        name        <- map["name"]
        hashtags    <- map["hashtags"]
        verified    <- map["verified"]
        desc        <- map["desc"]
        genres  <- map["music_types"]
        coverImages <- map["cover_images"]
        members     <- map["members"]
        igId        <- map["instagram_id"]
        fbId        <- map["facebook_id"]
    }
}

class BuskerMember: Mappable {
    var id: String?
    var name: String?
    var icon: Image?
    var role: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id      <- map["_id"]
        name    <- map["name"]
        icon    <- map["img"]
        role    <- map["part"]
    }
    
}

class BuskerEventsList: Mappable {
    var buskerId: String?
    var skip: Int?
    var limit: Int?
    var list = [Event]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        buskerId   <- map["profile_id"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
    
}

class BuskerPostsList: Mappable {
    var buskerId: String?
    var skip: Int?
    var limit: Int?
    var list = [Post]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        buskerId   <- map["profile_id"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
    
}


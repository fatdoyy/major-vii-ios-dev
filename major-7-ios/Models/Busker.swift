//
//  Busker.swift
//  major-7-ios
//
//  Created by jason on 14/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class BuskerList: Mappable {
    var skip: Int?
    var limit: Int?
    var list = [OrganizerProfile]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        skip    <- map["skip"]
        limit   <- map["limit"]
        list    <- map ["list"]
    }
}

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
    var tagline: String?
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
        tagline     <- map["tagline"]
        hashtags    <- map["hashtags"]
        verified    <- map["verified"]
        desc        <- map["desc"]
        genres      <- map["music_types"]
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
    var buskerID: String?
    var skip: Int?
    var limit: Int?
    var list = [Event]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        buskerID    <- map["profile_id"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
    
}

class BuskerPostsList: Mappable {
    var buskerID: String?
    var skip: Int?
    var limit: Int?
    var list = [Post]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        buskerID    <- map["profile_id"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
    
}

class OrganizerProfile: Mappable {
    var musicTypes = [String]()
    var coverImages = [Image]()
    var id: String?
    var name: String?
    var type: Int?
    var verified: Bool?
    var tagline: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        musicTypes      <- map["music_types"]
        coverImages     <- map["cover_images"]
        id              <- map["_id"]
        name            <- map["name"]
        type            <- map["type"]
        verified        <- map["verified"]
        tagline         <- map["tagline"]
    }
}

//Busker Followings
class BuskerFollowingsList: Mappable {
    var profileID: String?
    var skip: Int?
    var limit: Int?
    var list = [BuskerFollowingsObject]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        profileID   <- map["profile_id"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
}

class BuskerFollowingsObject: Mappable {
    var id: String?
    var user: FollowingUser?
    var createTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["_id"]
        user        <- map["user"]
        createTime  <- map["create_time"]
    }
}

class FollowingUser: Mappable {
    var id: String?
    var username: String?
    var displayName: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["_id"]
        username    <- map["username"]
        displayName <- map["display_name"]
    }
}

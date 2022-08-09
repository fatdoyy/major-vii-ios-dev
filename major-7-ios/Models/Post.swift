//
//  Post.swift
//  major-7-ios
//
//  Created by jason on 18/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class Posts: Mappable {
    var skip: Int?
    var limit: Int?
    var list = [Post]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
}

class Post: Mappable {
    var images = [M7Image]()
    var id: String?
    var content: String?
    var authorProfile: OrganizerProfile?
    var creatorType: String?
    var publishTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        images          <- map["images"]
        id              <- map["_id"]
        content         <- map["text"]
        authorProfile   <- map["creator_profile"]
        creatorType     <- map["creator_type"]
        publishTime     <- map["publish_time"]
    }
    
}

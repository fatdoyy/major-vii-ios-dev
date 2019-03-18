//
//  Post.swift
//  major-7-ios
//
//  Created by jason on 18/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class Post: Mappable {
    var images = [Image]()
    var id: String?
    var content: String?
    var createrProfile: OrganizerProfile?
    var creatorType: Int?
    var publishTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        images          <- map["images"]
        id              <- map["_id"]
        content         <- map["text"]
        createrProfile  <- map["cretor_profile"]
        creatorType     <- map["creator_type"]
        publishTime     <- map["publish_time"]
    }
    
}

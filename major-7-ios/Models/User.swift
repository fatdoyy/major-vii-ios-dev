//
//  User.swift
//  major-7-ios
//
//  Created by jason on 19/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class UserFollowings: Mappable {
    var list = [OrganizerProfileObject]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list    <- map["list"]
    }
}

class OrganizerProfileObject: Mappable {
    var targetProfile: OrganizerProfile?
    var targetType: String?
    var createTime: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        targetProfile   <- map["target_profile"]
        targetType      <- map["target_type"]
        createTime      <- map["create_time"]
    }
}

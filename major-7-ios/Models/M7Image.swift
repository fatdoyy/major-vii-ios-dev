//
//  Images.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class M7Image: Mappable {
    var publicID: String?
    var resID: String?
    var createTime: String?
    var format: String?
    var resourceType: String?
    var url: String?
    var width: CGFloat?
    var height: CGFloat?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        publicID        <- map["public_id"]
        resID           <- map["res_id"]
        createTime      <- map["create_time"]
        format          <- map["format"]
        resourceType    <- map["resource_type"]
        url             <- map["url"]
        width           <- map["width"]
        height          <- map["height"]
    }
}

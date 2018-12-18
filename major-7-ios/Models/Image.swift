//
//  Images.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class Image: Mappable {
    var publicId: String?
    var version: Int?
    var format: String?
    var resourceType: String?
    var url: String?
    var secureUrl: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        publicId        <- map["public_id"]
        version         <- map["version"]
        format          <- map["format"]
        resourceType    <- map["resource_type"]
        url             <- map["url"]
        secureUrl       <- map["secure_url"]
    }
}

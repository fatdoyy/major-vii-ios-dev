//
//  SearchResult.swift
//  major-7-ios
//
//  Created by jason on 19/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class BuskersSearchResult: Mappable {
    var keywords = [String]()
    var skip: Int?
    var limit: Int?
    var list = [OrganizerProfile]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        keywords    <- map["keywords"]
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
    
}

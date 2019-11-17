//
//  Genre.swift
//  major-7-ios
//
//  Created by jason on 17/11/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import ObjectMapper

class Genres: Mappable {
    var list = [Genre]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        list <- map["list"]
    }
}

class Genre: Mappable {
    var code: String?
    var titleEN: String?
    var titleTC: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        code    <- map["code"]
        titleEN <- map["title_en"]
        titleTC <- map["title_tc"]
    }
}

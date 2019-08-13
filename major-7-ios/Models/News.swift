//
//  News.swift
//  major-7-ios
//
//  Created by jason on 25/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import ObjectMapper

class NewsList: Mappable {
    var skip: Int?
    var limit: Int?
    var list = [News]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        skip        <- map["skip"]
        limit       <- map["limit"]
        list        <- map["list"]
    }
}

class NewsDetails: Mappable {
    var item: News?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        item     <- map["item"]
    }
}

class News: Mappable {
    var id: String?
    var isPublished: Bool?
    var publishTime: String?
    var type: Int?
    var cellType: Int?
    var title: String?
    var subTitle: String?
    var coverImages = [Image]()
    var videoUrl = [String]()
    var content: String?
    var contentUrl: String?
    var hashtags = [String]()
    //var viewCount: Int?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id              <- map["_id"]
        isPublished     <- map["published"]
        publishTime     <- map["publish_time"]
        type            <- map["type"]
        cellType        <- map["listing_template"]
        title           <- map["title"]
        subTitle        <- map["sub_title"]
        coverImages     <- map["cover_images"]
        videoUrl        <- map["videos"]
        content         <- map["content"]
        contentUrl      <- map["content_url"]
        hashtags        <- map["hashtags"]
        //viewCount       <- map["companyNameChi"]
    }
}




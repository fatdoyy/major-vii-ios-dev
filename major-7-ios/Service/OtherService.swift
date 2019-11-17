//
//  OtherService.swift
//  major-7-ios
//
//  Created by jason on 17/11/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper

class OtherService: BaseService {}

extension OtherService {
    static func getGenres() -> Promise<Genres> {
        return Promise { resolver in
            request(method: .get, url: getActionPath(.listOfMusicGenres)).done { response in
                guard let genreList = Mapper<Genres>().map(JSONObject: response) else {
                    resolver.reject(PMKError.cancelled)
                    return
                }
                
                resolver.fulfill(genreList)
                }.catch { error in
                    resolver.reject(error)
            }
        }
    }
}

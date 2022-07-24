//
//  Config.swift
//  major-7-ios
//
//  Created by jason on 22/7/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import Foundation

struct AppConfig: Decodable {
    var apiEndpoint: String
    var fbAppID: String
    var fbClientToken: String
    var fbDisplayName: String
    var googleMapsKey: String
}

extension Bundle {
     func appConfig() -> AppConfig? {
        var config: AppConfig?
        
        guard let fileUrl = Bundle.main.url(forResource: "AppConfig", withExtension: "plist") else { return config }
        if let data = try? Data(contentsOf: fileUrl) {
            let decoder = PropertyListDecoder()
            config = try? decoder.decode(AppConfig.self, from: data)
        }
        
        return config
    }
}

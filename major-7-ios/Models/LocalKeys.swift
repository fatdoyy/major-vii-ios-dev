//
//  LocalKeys.swift
//  major-7-ios
//
//  Created by jason on 17/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation

struct LOCAL_KEY {
    //major vii credentials
    static var USER_ID = "user_id"
    static var ACCESS_TOKEN = "access_token"
    static var REFRESH_TOKEN = "refresh_token"
    static var USERNAME = "username"
    
    //Apple Credentials (i.e. sign in with apple)
    static var APPLE_USER_ID = "apple_user_id"
    static var APPLE_IDENTITY_TOKEN = "apple_identity_token"
    static var APPLE_AUTH_CODE = "apple_auth_code"
    static var APPLE_USERNAME = "apple_username"
    static var APPLE_EMAIL = "apple_email"
    
    //User Settings
    static var GOOGLE_MAPS_STYLE = "google_maps_style"
}

//check key has value
extension UserDefaults {
    func hasValue(_ key: String) -> Bool {
        return nil != object(forKey: key)
    }
}

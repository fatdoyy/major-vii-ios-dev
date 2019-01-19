//
//  NotificationNames.swift
//  major-7-ios
//
//  Created by jason on 19/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let loginCompleted = Notification.Name("loginCompleted")
    
    static let refreshBookmarkedSection = Notification.Name("refreshBookmarkedSection")
    static let refreshTrendingSectionCell = Notification.Name("refreshTrendingSectionCell")
    static let initTredingSectionIndexArray = Notification.Name("initTredingSectionIndexArray")
    
    static let removeTrendingSectionObservers = Notification.Name("removeTrendingSectionObservers")
    static let removeBookingSectionObservers = Notification.Name("removeBookingSectionObservers")

}

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
    static let refreshBookmarkedSectionFromDetails = Notification.Name("refreshBookmarkedSectionFromDetails")
    
    static let refreshTrendingSectionCell = Notification.Name("refreshTrendingSectionCell")
    
    static let removeBookmarkedSectionObservers = Notification.Name("removeBookmarkedSectionObservers")
    static let removeTrendingSectionObservers = Notification.Name("removeTrendingSectionObservers")
    
    
}

extension NotificationCenter {
    func setObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name, object: AnyObject?) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}

//
//  NotificationNames.swift
//  major-7-ios
//
//  Created by jason on 19/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let showLoginVC = Notification.Name("showLoginVC")
    static let loginCompleted = Notification.Name("loginCompleted")
    
    //Events
    static let refreshEventListVC = Notification.Name("refreshEventListVC")
    static let eventListEndRefreshing = Notification.Name("eventListEndRefreshing")
    
    static let refreshTrendingSection = Notification.Name("refreshTrendingSection") //pull to refresh
    static let refreshTrendingSectionCell = Notification.Name("refreshTrendingSectionCell") //bookmarkbtn state
    
    static let refreshFollowingSection = Notification.Name("refreshFollowSection") //pull to refresh
    static let refreshFollowingSectionCell = Notification.Name("refreshFollowingSectionCell") //bookmarkbtn state
    
    static let refreshBookmarkedSection = Notification.Name("refreshBookmarkedSection")
    
    static let refreshFeaturedSectionCell = Notification.Name("refreshFeaturedSection") //bookmarkbtn state
    
    static let removeBookmarkedSectionObservers = Notification.Name("removeBookmarkedSectionObservers")
    static let removeFollowingSectionObservers = Notification.Name("removeFollowingSectionObservers")
    static let removeTrendingSectionObservers = Notification.Name("removeTrendingSectionObservers")
    
    //Search controller notifications
    static let showSCViews = Notification.Name("showSCViews")
    static let hideSCViews = Notification.Name("hideSCViews")
    static let updateSearchBarText = Notification.Name("updateSearchBarText")
    static let hideSearchBarIndicator = Notification.Name("hideSearchBarIndicator")
    
    //dismiss keyboard
    static let dismissKeyboard = Notification.Name("dismissKeyboard")
}

extension NotificationCenter {
    func setObserver(_ observer: AnyObject, selector: Selector, name: NSNotification.Name, object: AnyObject?) {
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}

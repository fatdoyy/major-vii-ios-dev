//
//  NetworkReachbility.swift
//  major-7-ios
//
//  Created by jason on 24/10/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Foundation
import Reachability

class NetworkManager: NSObject {
    
    var reachability: Reachability!
    
    // Create a singleton instance
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    override init() {
        super.init()
        
        // Initialise reachability
        do {
            try reachability = Reachability()
        } catch {
            print("Unable to init reachability")
        }
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            // Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}

extension NetworkManager {
    static func checkNetworkReachability() {
        NetworkManager.sharedInstance.reachability.whenUnreachable = { reachability in
            print("unreachable")
//            if let offlineLabel = self.offlineLabel {
//                offlineLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//                offlineLabel.textColor = .lightGray
//                offlineLabel.backgroundColor = .m7DarkGray()
//                offlineLabel.alpha = 0
//                offlineLabel.tag = 333
//                offlineLabel.numberOfLines = 0
//                offlineLabel.text = "You're offline! \nPlease check your network settings."
//                offlineLabel.textAlignment = .center
//                self.view.addSubview(offlineLabel)
//                offlineLabel.snp.makeConstraints { (make) in
//                    make.center.equalToSuperview()
//                    make.size.equalToSuperview()
//                }
//
//                UIView.animate(withDuration: 0.2) {
//                    offlineLabel.alpha = 1
//                    self.mainCollectionView.alpha = 0
//                }
//            }
        }
        
         NetworkManager.sharedInstance.reachability.whenReachable = { _ in
            print("reachable!")
//            self.getNews(limit: self.newsLimit)
//            self.delegate?.refreshUpcomingEvents()
//
//            if let offlineLabel = self.view.viewWithTag(333) {
//                UIView.animate(withDuration: 0.2) {
//                    offlineLabel.alpha = 0
//                    self.mainCollectionView.alpha = 1
//                }
//                offlineLabel.removeFromSuperview()
//            }
        }
    }
}

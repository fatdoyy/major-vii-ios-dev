//
//  NetworkReachbility.swift
//  major-7-ios
//
//  Created by jason on 24/10/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import SwiftMessages
import Alamofire

class NetworkManager {
    //shared instance
    static let sharedInstance = NetworkManager()
    
    let reachabilityManager = NetworkReachabilityManager()
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening { status in
            switch status {
            case .notReachable:
                print("The network is not reachable")
                SwiftMessages.show(config: InAppNotifications.foreverDurationConfig(),view: InAppNotifications.offlineWarning())
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                SwiftMessages.hide()
                
            case .reachable(.cellular):
                print("The network is reachable over the WWAN connection")
                SwiftMessages.hide()
                
            case .unknown :
                print("It is unknown whether the network is reachable")
            }
        }
    }
}

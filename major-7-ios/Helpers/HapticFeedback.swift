//
//  HapticFeedback.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HapticFeedback {
    
    //impact
    static func createImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .heavy:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        default:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        }
    }
    
    //selection
    static func createSelectionFeedback() {
        let selection = UISelectionFeedbackGenerator()
        selection.selectionChanged()
    }
    
    //notification
    static func createNotificationFeedback(style: UINotificationFeedbackGenerator.FeedbackType) {
        let notification = UINotificationFeedbackGenerator()
        switch style {
        case .warning:  notification.notificationOccurred(.warning)
        case .error:    notification.notificationOccurred(.error)
        default:        notification.notificationOccurred(.success)
        }
    }
}

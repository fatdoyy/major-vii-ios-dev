//
//  DateTimeHelper.swift
//  major-7-ios
//
//  Created by jason on 13/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SwiftDate

class DateTimeHelper {}

extension DateTimeHelper {
    static func getEventInterval(from: DateInRegion, to: DateInRegion) -> String {
        let dayDifference = from.getInterval(toDate: to, component: .day)
        switch dayDifference {
        case ..<0:  return "Ongoing / Ended"
        case 0:     return "Today"
        case 1:     return "1 day later"
            
        case 30...: //calculate in months
            let monthDifference = from.getInterval(toDate: to, component: .month)
            switch monthDifference {
            case 1:     return "1 month later"
            case 12...: return "1 year later"
            default:    return "\(monthDifference) months later"
            }
            
        default:    return "\(dayDifference) days later"
        }
    }
    
    static func getNewsOrPostInterval(from: DateInRegion, to: DateInRegion) -> String {
        let dayDifference = from.getInterval(toDate: to, component: .day)
        switch dayDifference {
        case -1:        return "Yesterday"
        case 0:         return "Today"
        case ..<(-1):   return "\(abs(dayDifference)) days ago"
        case (-365)...: return "1 year ago"
        default:        return "\(abs(dayDifference)) days ago"
        }
    }
}



//
//  Colors.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    // MARK: General UI Colors
    class func darkColor() -> UIColor {
        return UIColor(red:0.12, green:0.12, blue:0.14, alpha:1.0)
    }
    
    
    // MARK: Text Colors
    class func whiteText() -> UIColor {
        return UIColor.white
    }
    
    class func whiteText25Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.25)
    }
    
    class func whiteText50Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.5)
    }
    
    class func whiteText75Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.75)
    }
}

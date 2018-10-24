//
//  Colors.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import DynamicColor

// MARK: UIColor extension

extension UIColor {
    
    //General UI Colors
    class func darkGray() -> UIColor {
        return UIColor(red:0.12, green:0.12, blue:0.14, alpha:1.0)
    }
    
    class func lightPurple() -> UIColor {
        return UIColor(hexString: "#3498db")
    }
    
    class func darkPurple() -> UIColor {
        return UIColor(hexString: "#854cc5")
    }
    
    //Text Colors
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

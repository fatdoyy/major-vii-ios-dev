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
        return UIColor(hexString: "#1E1E24")
    }
    
    class func charcoal() -> UIColor {
        return UIColor(hexString: "#292b32")
    }
    
    class func lightPurple() -> UIColor {
        return UIColor(hexString: "#c86dd7")
    }
    
    class func darkPurple() -> UIColor {
        return UIColor(hexString: "#854cc5")
    }
    
    class func mintGreen() -> UIColor {
        return UIColor(hexString: "#51B79F")
    }
    
    class func fbBlue() -> UIColor {
        return UIColor(hexString: "#3b5998")
    }

    class func white15Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.15)
    }
    
    class func white50Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.50)
    }
    
    class func white75Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.75)
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
    
    class func whiteText80Alpha() -> UIColor {
        return UIColor.white.withAlphaComponent(0.8)
    }

    class func purpleText() -> UIColor {
        return UIColor(hexString: "#7e7ecf")
    }
    
    class func topazText() -> UIColor {
        return UIColor(hexString: "16ccbd")
    }
    
    class func lightGrayText() -> UIColor {
        return UIColor(hexString: "#afafaf")
    }
    
    class func darkGrayText() -> UIColor {
        return UIColor(hexString: "#797979")
    }
}

//turn UIColor to cgColor
extension Array where Element == UIColor {
    func cgColors() -> [CGColor] {
        var cgColorArray: [CGColor] = []
        
        for color in self {
            cgColorArray.append(color.cgColor)
        }
        
        return cgColorArray
    }
}

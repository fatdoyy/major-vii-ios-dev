//
//  GradientLayer.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class GradientLayer {
    
    static func create(frame: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint, locations: [NSNumber]? = nil, cornerRadius: Bool? = nil) -> CAGradientLayer {
        let gradientBg = CAGradientLayer()
        gradientBg.frame = frame
        gradientBg.colors = colors.cgColors()
        
        if let locations = locations {
            gradientBg.locations = locations
        }
        
        if cornerRadius == true {
            gradientBg.cornerRadius = GlobalCornerRadius.value
        }
       
        gradientBg.startPoint = startPoint
        gradientBg.endPoint = endPoint

        return gradientBg
    }
    
}

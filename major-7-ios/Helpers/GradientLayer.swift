//
//  GradientLayer.swift
//  major-7-ios
//
//  Created by jason on 17/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class GradientLayer {
    
    static func create(frame: CGRect) -> CAGradientLayer {
        let gradientBg = CAGradientLayer()
        gradientBg.colors = [UIColor.lightPurple().cgColor, UIColor.darkPurple().cgColor]
        gradientBg.frame = frame
        gradientBg.cornerRadius = GlobalCornerRadius.value
        gradientBg.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBg.endPoint = CGPoint(x: 1, y: 0.5)

        return gradientBg
    }
    
}

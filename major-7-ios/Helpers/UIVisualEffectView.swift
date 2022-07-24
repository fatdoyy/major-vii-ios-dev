//
//  UIVisualEffectView.swift
//  major-7-ios
//
//  Created by jason on 14/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class VisualEffectView {
    class func create() -> UIVisualEffectView {
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.layer.cornerRadius = GlobalCornerRadius.value
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false        
        return blurView
    }
    
}

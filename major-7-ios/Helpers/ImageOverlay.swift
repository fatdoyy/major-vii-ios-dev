//
//  ImageOverlay.swift
//  major-7-ios
//
//  Created by jason on 2/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class ImageOverlay: UIView { //Black at bottom
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.65).cgColor
        ]
        backgroundColor = UIColor.clear
    }
}

class ImageOverlayRevert: UIView { //Black at top 
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.65).cgColor,
            UIColor.clear.cgColor
        ]
        
        backgroundColor = UIColor.clear
    }
}

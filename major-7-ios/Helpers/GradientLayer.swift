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

class Gradient {
    static func createOverlay(cell: BuskerCell, imgHeight: CGFloat) {
        if !cell.didCreateOverlay {
            let gradientBg = UIView()
            gradientBg.layer.insertSublayer(GradientLayer.create(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: imgHeight - 47), colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
            gradientBg.backgroundColor = .clear
            gradientBg.alpha = 0.45
            
            cell.addSubview(gradientBg)
            gradientBg.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-47)
            }
            cell.didCreateOverlay = true
        } else {
            print("created!")
        }
    }
}


//create GradientOverlay class to idetify them in all subviews
class GradientOverlay: UIView {
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

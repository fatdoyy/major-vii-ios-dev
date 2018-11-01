//
//  Animations.swift
//  major-7-ios
//
//  Created by jason on 30/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import UIKit

class Animations {
    
    static func bounce(_ bounce: Bool, view: UIView) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.8,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: { view.transform = bounce ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity },
            completion: nil)
    }
}

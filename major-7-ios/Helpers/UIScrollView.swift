//
//  UIScrollView.swift
//  major-7-ios
//
//  Created by jason on 22/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

extension UIScrollView {
    var currentVerticalPage: Int {
        return Int((self.contentOffset.y + (0.5 * self.frame.size.height)) / self.frame.height)
    }
    
    var currentHorizontalPage: Int {
        return Int((self.contentOffset.x + (0.5 * self.frame.size.width)) / self.frame.width)
    }
}

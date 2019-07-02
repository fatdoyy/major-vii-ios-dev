//
//  CustomRefreshControl.swift
//  major-7-ios
//
//  Created by jason on 2/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CustomRefreshControl: UIView {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var indicator: NVActivityIndicatorView!

}

extension CustomRefreshControl {
    func setupUI() {
        indicator.type = .lineScale
        indicator.color = .blue
    }
}

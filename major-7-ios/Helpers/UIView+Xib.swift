//
//  UIView+Xib.swift
//  major-7-ios
//
//  Created by jason on 9/1/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

extension UIView {
    func loadXibView(with xibFrame: CGRect) -> UIView {
        let className = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: className, bundle: bundle)
        guard let xibView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else {
            return UIView()
        }
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        xibView.frame = xibFrame
        return xibView
    }
}

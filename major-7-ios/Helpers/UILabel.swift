//
//  UILabel.swift
//  major-7-ios
//
//  Created by jason on 22/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

extension UILabel {
    func textHeight(withWidth width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.height(withWidth: width, font: font)
    }
    
    func attributedTextHeight(withWidth width: CGFloat) -> CGFloat {
        guard let attributedText = attributedText else {
            return 0
        }
        return attributedText.height(withWidth: width)
    }
}

extension String {
    func height(withWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension NSAttributedString {
    
    func height(withWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: withWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }
    
    func width(withHeight: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: withHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.width)
    }
    
}


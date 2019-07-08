//
//  TextAttributes.swift
//  major-7-ios
//
//  Created by jason on 8/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class TextAttributes {}

extension TextAttributes {
    class func newsContentConfig() -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        return myAttribute
    }
    
    class func postContentConfig() -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        //paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        return myAttribute
    }
}

//
//  HeaderView.swift
//  major-7-ios
//
//  Created by jason on 23/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift

class HeaderView: UICollectionReusableView {

    static let reuseIdentifier: String = "header"

    internal static let height: CGFloat = 58
    
    @IBOutlet weak var newsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        newsTitle.text = "News"
        newsTitle.textColor = .whiteText()
    }
    
}

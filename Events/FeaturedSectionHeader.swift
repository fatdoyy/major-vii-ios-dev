//
//  FeaturedSectionHeader.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class FeaturedSectionHeader: UICollectionReusableView {

    static let reuseIdentifier = "featuredSectionHeader"
    
    static let height: CGFloat = 88
    
    @IBOutlet weak var featuredTitle: UILabel!
    @IBOutlet weak var featuredCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        featuredTitle.textColor = .whiteText()
        featuredTitle.text = "Featured"
        
        featuredCountLabel.textColor = .purpleText()
        featuredCountLabel.text = "100+ Events"
    }
    
}

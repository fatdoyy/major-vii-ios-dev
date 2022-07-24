//
//  HeaderView.swift
//  major-7-ios
//
//  Created by jason on 23/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift

class HomeHeaderView: UICollectionReusableView {

    static let reuseIdentifier: String = "homeHeaderView"

    internal static let height: CGFloat = 87
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var premiumBadge: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        newsTitle.alpha = 0
        newsTitle.text = "News"
        newsTitle.textColor = .whiteText()
        
        appIcon.alpha = UserService.current.isLoggedIn() ? 0 : 1
        
        premiumBadge.alpha = UserService.current.isLoggedIn() ? 1 : 0
    }
    
}

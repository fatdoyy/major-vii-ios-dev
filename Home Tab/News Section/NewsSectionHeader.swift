//
//  NewsSection.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class NewsSectionHeader: UICollectionViewCell{

    static let reuseIdentifier: String = "newsHeader"
    
    static let height: CGFloat = 74 //height form xib frame
    
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        newsLabel.text = "News"
        newsLabel.textColor = .whiteText()
        
        postsLabel.text = "Posts?"
        postsLabel.textColor = .whiteText25Alpha()
    }

}

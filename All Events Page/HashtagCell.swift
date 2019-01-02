//
//  HashtagCell.swift
//  major-7-ios
//
//  Created by jason on 27/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HashtagCell: UICollectionViewCell {
    
    static let reuseIdentifier = "detailsViewHashtagCell"
    
    static let height: CGFloat = 24
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var hashtag: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        bgView.backgroundColor = .white15Alpha()
        bgView.layer.cornerRadius = GlobalCornerRadius.value - 4
        
        hashtag.textColor = .lightGray
    }
}



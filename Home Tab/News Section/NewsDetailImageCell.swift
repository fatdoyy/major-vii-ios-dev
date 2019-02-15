//
//  NewsDetailImageCell.swift
//  major-7-ios
//
//  Created by jason on 15/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class NewsDetailImageCell: UICollectionViewCell {

    static let reuseIdentifier = "newsDetailImageCell"
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.backgroundColor = .darkGray
    }

}

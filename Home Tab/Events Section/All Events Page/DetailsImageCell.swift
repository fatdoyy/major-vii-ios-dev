//
//  DetailsImageCell.swift
//  major-7-ios
//
//  Created by jason on 3/12/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class DetailsImageCell: UICollectionViewCell {

    static let reuseIdentifier = "detailsImageCell"
    
    static let width: CGFloat = 120
    static let height: CGFloat = 120
    
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.backgroundColor = .darkGray
        imgView.layer.cornerRadius = GlobalCornerRadius.value - 4
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
    }

}

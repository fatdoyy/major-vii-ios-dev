//
//  BuskerCell.swift
//  major-7-ios
//
//  Created by jason on 19/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerCell: UICollectionViewCell {

    static let reuseIdentifier = "buskerCell"
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var buskerName: UILabel!
    @IBOutlet weak var genre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = GlobalCornerRadius.value
        
        containerView.backgroundColor = .darkGray()
        
        imgView.backgroundColor = .darkGray
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = GlobalCornerRadius.value
        imgView.clipsToBounds = true
        
        buskerName.numberOfLines = 0
        buskerName.textColor = .white
        
        genre.numberOfLines = 1
        genre.textColor = .white
    }

}

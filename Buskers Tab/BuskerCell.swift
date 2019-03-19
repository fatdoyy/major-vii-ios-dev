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
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelBgView: UIView!
    @IBOutlet weak var buskerName: UILabel!
    @IBOutlet weak var genre: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = GlobalCornerRadius.value
        
        imgView.backgroundColor = .darkGray
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = GlobalCornerRadius.value
        imgView.clipsToBounds = true
        
        labelBgView.backgroundColor = .orange
        
        buskerName.textColor = .white
        genre.textColor = .white
    }

}

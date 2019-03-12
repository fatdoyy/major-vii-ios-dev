//
//  BuskerProfilePostCell.swift
//  major-7-ios
//
//  Created by jason on 12/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerProfilePostCell: UICollectionViewCell {

    static let reuseIdentifier = "buskerProfilePostCell"
    static let width: CGFloat = 335
    static let height: CGFloat = 422
    
    @IBOutlet weak var buskerIcon: UIImageView!
    @IBOutlet weak var buskerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moreIcon: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buskerIcon.layer.cornerRadius = 32
        buskerLabel.textColor = .white
        timeLabel.textColor = .white
        contentLabel.textColor = .white
        
    }

}

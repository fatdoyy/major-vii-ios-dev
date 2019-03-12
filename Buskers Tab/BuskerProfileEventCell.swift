//
//  BuskerProfileEventCell.swift
//  major-7-ios
//
//  Created by jason on 12/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerProfileEventCell: UICollectionViewCell {

    static let reuseIdentifier = "buskerProfileEventCell"
    static let width: CGFloat = 295
    static let height: CGFloat = 200
    
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bookmarkCount: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventImg.layer.cornerRadius = GlobalCornerRadius.value / 2
        
        eventLabel.textColor = .white
        locationLabel.textColor = .white
        bookmarkCount.textColor = .white
        timeLabel.textColor = .white
    }

}

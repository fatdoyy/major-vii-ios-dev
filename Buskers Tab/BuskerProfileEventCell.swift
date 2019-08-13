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
    static let width: CGFloat = UIScreen.main.bounds.width - 80
    static let height: CGFloat = 200
    
    @IBOutlet weak var eventImg: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var bookmarkCount: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventImg.layer.cornerRadius = GlobalCornerRadius.value / 2
        
        eventLabel.textColor = .white
        locationLabel.textColor = .white
        bookmarkCount.textColor = .white
        dateLabel.textColor = .white
    }

}

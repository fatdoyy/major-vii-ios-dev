//
//  BuskerProfileMemberCell.swift
//  major-7-ios
//
//  Created by jason on 8/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class BuskerProfileMemberCell: UICollectionViewCell {

    static let reuseIdentifier = "buskerProfileMemberCell"
    static let width: CGFloat = 112
    static let height: CGFloat = 120
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleBg: UIView!
    @IBOutlet weak var roleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        icon.layer.cornerRadius = 36 //height is 72
        
        nameLabel.textColor = .white
        nameLabel.text = "Default"
        
        roleBg.layer.cornerRadius = 8
        roleBg.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        roleLabel.textColor = .white
        roleLabel.text = "Default"
    }

}

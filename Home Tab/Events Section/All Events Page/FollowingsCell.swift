//
//  FollowingsCell.swift
//  major-7-ios
//
//  Created by jason on 8/8/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class FollowingsCell: UICollectionViewCell {
    static let reuseIdentifier = "followingsCell"
    
    static let height: CGFloat = 24
    
    var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
        layer.cornerRadius = GlobalCornerRadius.value / 1.5
        
        name = UILabel()
        name.textColor = .purpleText()
        name.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        addSubview(name)
        name.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(24)
        }
    }

}

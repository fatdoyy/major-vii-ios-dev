//
//  NewsCellType2.swift
//  major-7-ios
//
//  Created by jason on 25/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SnapKit

class NewsCellType2: UICollectionViewCell {
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        
        //newsTitle.lineBreakMode = .byWordWrapping
        newsTitle.numberOfLines = 0
        newsTitle.text = "123"
        newsTitle.textColor = .whiteText()
        
        timeLabel.text = "3 days ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "2,636"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: NewsCellType1.cellWidth, height: NewsCellType1.cellHeight)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = 12
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType1.cellWidth)
            make.height.equalTo(NewsCellType1.cellHeight)
        }
        sendSubviewToBack(bgImgView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}

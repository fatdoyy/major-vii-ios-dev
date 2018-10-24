//
//  NewsCell.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SnapKit

class NewsCell: UICollectionViewCell {
    
    static let cellWidth = UIScreen.main.bounds.width - 40 // minus leading (20pt) and trailing (20pt) space
    static let cellHeight: CGFloat = 258
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        
        //newsTitle.lineBreakMode = .byWordWrapping
        newsTitle.numberOfLines = 0
        newsTitle.text = "JL is releasing an brand new album."
        newsTitle.textColor = .whiteText()
        
        timeLabel.text = "1 month ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "12,843"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = 12
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCell.cellWidth)
            make.height.equalTo(NewsCell.cellHeight)
        }
        sendSubviewToBack(bgImgView)
    }

}

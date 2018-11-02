//
//  NewsCell.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SnapKit

class NewsCellType1: UICollectionViewCell {
        
    static let aspectRatio: CGFloat = 335.0 / 258.0 //according to zeplin
    static let cellWidth = UIScreen.main.bounds.width - 40 // minus leading (20pt) and trailing (20pt) space
    static let cellHeight = cellWidth / aspectRatio
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()

        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = 12
        
        //newsTitle.lineBreakMode = .byWordWrapping
        newsTitle.numberOfLines = 0
        newsTitle.textColor = .whiteText()
        
        timeLabel.text = "1 month ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "12,843"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: NewsCellType1.cellWidth, height: NewsCellType1.cellHeight)
        bgImgView.backgroundColor = .gray
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
        bgImgView.sd_cancelCurrentImageLoad()
        bgImgView.image = nil
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.bounce(isHighlighted, view: self) }
    }
}

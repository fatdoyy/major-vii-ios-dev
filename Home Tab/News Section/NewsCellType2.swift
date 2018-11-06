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
    
    static let reuseIdentifier: String = "newsCell2"
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageOverlay: ImageOverlayRevert!
    
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        
        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = 12
        
        //newsTitle.lineBreakMode = .byWordWrapping
        newsTitle.numberOfLines = 0
        newsTitle.textColor = .whiteText()
        
        timeLabel.text = "3 days ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "2,636"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: NewsCellType1.width, height: NewsCellType1.height)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = 12
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType1.width)
            make.height.equalTo(NewsCellType1.height)
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

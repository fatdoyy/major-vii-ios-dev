//
//  NewsCellType3.swift
//  major-7-ios
//
//  Created by jason on 25/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class NewsCellType3: UICollectionViewCell {

    static let reuseIdentifier: String = "newsCell3"
    
    private typealias `Self` = NewsCellType3
    
    static let aspectRatio: CGFloat = 335.0 / 203.0 //template 3 ratio according to zeplin
    static let cellWidth = NewsCellType1.width
    static let cellHeight: CGFloat = cellWidth / aspectRatio
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        
        newsTitle.lineBreakMode = .byTruncatingTail
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: //iPhone SE
                newsTitle.numberOfLines = 1 //limiting the number of lines on iPhone SE because the screen is too small and will cause layout problems
            default:
                newsTitle.numberOfLines = 2
            }
        }
        
        newsTitle.textColor = .whiteText()
        
        subTitle.textColor = .whiteText()
        
        timeLabel.text = "3 days ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "2,636"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: Self.cellWidth, height: Self.cellHeight)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = 12
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(Self.cellWidth)
            make.height.equalTo(Self.cellHeight)
        }
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(hexString: "333333").withAlphaComponent(0.75)
        overlayView.layer.cornerRadius = 12
        overlayView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(Self.cellWidth)
            make.height.equalTo(Self.cellHeight)
        }
        sendSubviewToBack(bgImgView)
        insertSubview(overlayView, aboveSubview: bgImgView)
        
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

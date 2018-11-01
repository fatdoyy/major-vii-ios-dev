//
//  NewsCellType5.swift
//  major-7-ios
//
//  Created by jason on 26/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Pastel

class NewsCellType5: UICollectionViewCell {

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
        layer.cornerRadius = 12
        
        let gradientBg = PastelView()
        gradientBg.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType3.cellWidth)
            make.height.equalTo(NewsCellType3.cellHeight)
        }
        
        // Custom Direction
        gradientBg.startPastelPoint = .bottomLeft
        gradientBg.endPastelPoint = .topRight
        
        // Custom Duration
        gradientBg.animationDuration = 3.0
        
        // Custom Color
        gradientBg.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        gradientBg.startAnimation()
        insertSubview(gradientBg, at: 0)
        
        newsTitle.lineBreakMode = .byTruncatingTail
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: //iPhone SE
                newsTitle.numberOfLines = 1 //limiting the number of lines on iPhone SE because the screen is too small and will cause layout problems
            default:
                newsTitle.numberOfLines = 2
            }
        }
        
        newsTitle.text = "Clockenflap 2018"
        newsTitle.textColor = .whiteText()
        
        subTitle.text = ""
        subTitle.textColor = .whiteText()
        
        timeLabel.text = "3 days ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "2,636"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.bounce(isHighlighted, view: self) }
    }
}

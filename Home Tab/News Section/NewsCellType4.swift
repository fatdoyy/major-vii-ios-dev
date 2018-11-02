//
//  NewsCellType4.swift
//  major-7-ios
//
//  Created by jason on 26/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Pastel
import SkeletonView

class NewsCellType4: UICollectionViewCell {
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dummyTagLabel: UILabel!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    
    var gradientBg = PastelView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
        layer.cornerRadius = 12
        
        gradientBg.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType3.cellWidth)
            make.height.equalTo(NewsCellType3.cellHeight)
        }
        
        // Custom Direction
        gradientBg.startPastelPoint = .bottomLeft
        gradientBg.endPastelPoint = .topRight
        
        // Custom Duration
        gradientBg.animationDuration = 2.5
        
        // Custom Color
        gradientBg.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        //gradientBg.startAnimation()
        insertSubview(gradientBg, at: 0)
        //gradientBg.isHidden = true
        
        SkeletonAppearance.default.multilineCornerRadius = 6
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: .gray)
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136: //iPhone SE
                newsTitle.numberOfLines = 1 //limiting the number of lines on iPhone SE because the screen is too small and will cause layout problems
            default:
                newsTitle.numberOfLines = 2
            }
        }
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        newsTitle.tag = 1
        dummyTagLabel.tag = 2
        for view in skeletonViews{
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 20
            } else {
                SkeletonAppearance.default.multilineHeight = 15
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
        
        newsTitle.lineBreakMode = .byTruncatingTail
        newsTitle.lastLineFillPercent = 70
        newsTitle.textColor = .whiteText()
        
        subTitle.textColor = .whiteText()
        
        timeLabel.textColor = .whiteText()
        
        countLabel.textColor = .whiteText()
        
        viewsLabel.textColor = .whiteText()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.bounce(isHighlighted, view: self) }
    }
    
}

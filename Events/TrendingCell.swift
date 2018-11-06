//
//  TrendingCell.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

class TrendingCell: UICollectionViewCell {

    static let reuseIdentifier: String = "trendingCell"
    
    private typealias `Self` = TrendingCell
    
    static let aspectRatio: CGFloat = 335.0 / 210.0 //ratio according to zeplin
    static let width = UIScreen.main.bounds.width - 40
    static var height: CGFloat = width / aspectRatio
    //static var height: CGFloat?
    
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageOverlay: ImageOverlay!

    @IBOutlet var skeletonViews: Array<UILabel>!
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        layer.cornerRadius = 12
        
        //print("cell.frame.height = \(self.frame.height)")
        
        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = 12
        
        SkeletonAppearance.default.multilineCornerRadius = 6
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: .gray)
        
//        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
//        eventTitle.tag = 1
//        for view in skeletonViews{
//            if view.tag == 1 {
//                SkeletonAppearance.default.multilineHeight = 20
//            } else {
//                SkeletonAppearance.default.multilineHeight = 15
//            }
//            view.isSkeletonable = true
//            view.showAnimatedGradientSkeleton(animation: animation)
//        }
        
        eventTitle.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        dateLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: Self.width, height: Self.height)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = 12
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(Self.width)
            make.height.equalTo(Self.height)
        }
        sendSubviewToBack(bgImgView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("TrendingCell.height = \(self.frame.size.height)")
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.bounce(isHighlighted, view: self) }
    }
}

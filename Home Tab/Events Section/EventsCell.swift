//
//  EventsCell.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

class EventsCell: UICollectionViewCell {

    static let reuseIdentifier: String = "eventCell"
    
    static let width: CGFloat = 198
    static let height: CGFloat = 96
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var imgOverlay: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
        layer.cornerRadius = GlobalCornerRadius.value
        
        setupViews()
        
        SkeletonAppearance.default.multilineCornerRadius = Int(GlobalCornerRadius.value / 2)
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: .gray)
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        dateLabel.tag = 1
        for view in skeletonViews{
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 18
            } else {
                SkeletonAppearance.default.multilineHeight = 14
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
    }

    private func setupViews(){
        imgOverlay.isHidden = true
        dateLabel.textColor = .whiteText()
        eventLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        //bgImgView.image = UIImage(named: "cat")
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: imgOverlay!.bounds, colors: [.white, UIColor.white.withAlphaComponent(0)]), at: 0)
    }
}

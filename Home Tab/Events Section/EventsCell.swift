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
    
    static let reuseIdentifier: String = "upcomingEventCell"
    
    static let width: CGFloat = 198
    static let height: CGFloat = 96
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var imgOverlay: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    @IBOutlet var skeletonViews: Array<UIView>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
        layer.cornerRadius = GlobalCornerRadius.value
        
        setupUI()
        setupSkeletonViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .darkGray
        
        if let sublayers = bgView.layer.sublayers {
            for sublayer in sublayers {
                if sublayer.name == "colorGradientLayer" {
                    sublayer.removeFromSuperlayer()
                }
            }
        }
        bgView.alpha = 1
        bgImgView.image = nil
        imgOverlay.isHidden = true
        verifiedIcon.alpha = 0

        setupSkeletonViews()
    }
}

//MARK: UI related
extension EventsCell {
    private func setupUI() {
        imgOverlay.isHidden = true
        dateLabel.textColor = .whiteText()
        eventLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: imgOverlay!.bounds, colors: [.white, UIColor.white.withAlphaComponent(0)], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5)), at: 0)
        verifiedIcon.alpha = 0
    }
    
    private func setupSkeletonViews() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        dateLabel.tag = 1
        for view in skeletonViews {
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 15
            } else {
                SkeletonAppearance.default.multilineHeight = 13
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
    }
}

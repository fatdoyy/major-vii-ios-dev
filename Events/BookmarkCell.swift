//
//  BookmarkCell.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

class BookmarkCell: UICollectionViewCell {

    static let reuseIdentifier = "bookmarkCell"
    
    static let width: CGFloat = 137
    static let height: CGFloat = 166
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        bgView.layer.cornerRadius = GlobalCornerRadius.value
        
        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = GlobalCornerRadius.value
        
        SkeletonAppearance.default.multilineCornerRadius = Int(GlobalCornerRadius.value / 2)
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
        byLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        dateLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: bgView.frame.width, height: bgView.frame.height)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.backgroundColor = .lightGray
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.clipsToBounds = true
        
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(bgView.frame.width)
            make.height.equalTo(bgView.frame.height)
        }
        bgView.addSubview(bgImgView)
        bgView.sendSubviewToBack(bgImgView)
    }
    
}

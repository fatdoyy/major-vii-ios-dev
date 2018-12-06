//
//  FollowingCell.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

protocol FollowingCellDelegate {
    func bookmarkBtnTapped()
}

class FollowingCell: UICollectionViewCell {

    static let reuseIdentifier = "followingCell"
    
    var delegate: FollowingCellDelegate?
    
    static let width: CGFloat = 138
    static let height: CGFloat = 166
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        
        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = GlobalCornerRadius.value
        
        bookmarkBtn.backgroundColor = .clear
        bookmarkBtn.layer.cornerRadius = GlobalCornerRadius.value / 3
        bookmarkBtn.layer.shadowColor = UIColor.black.cgColor
        bookmarkBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        bookmarkBtn.layer.shadowRadius = 5
        bookmarkBtn.layer.shadowOpacity = 0.7
        
        bookmarkCountLabel.textColor = .whiteText()
        
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
    }

    @IBAction func bookmarkBtnTapped(_ sender: Any) {
        if (self.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //bookmarked
            HapticFeedback.createImpact(style: .heavy)
            UIView.animate(withDuration: 0.2, animations: {
                self.bookmarkBtn.backgroundColor = .mintGreen()
            })
        } else { //remove bookmark
            HapticFeedback.createImpact(style: .light)
            UIView.animate(withDuration: 0.2, animations: {
                self.bookmarkBtn.backgroundColor = .clear
            })
        }
        delegate?.bookmarkBtnTapped()
    }
}

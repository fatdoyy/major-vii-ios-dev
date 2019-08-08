//
//  FollowingSectionCell.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView
import NVActivityIndicatorView

protocol FollowingSectionCellDelegate: class {
    func bookmarkBtnTapped(cell: FollowingSectionCell, tappedIndex: IndexPath)
}

class FollowingSectionCell: UICollectionViewCell {
    static let reuseIdentifier = "followingSectionCell"
    
    weak var delegate: FollowingSectionCellDelegate?
    var myIndexPath: IndexPath!
    
    static let width: CGFloat = 138
    static let height: CGFloat = 166
    
    var eventID: String = ""
    
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var byLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    var bookmarkBtnIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 12)), type: .lineScale)
    
    @IBOutlet var skeletonViews: Array<UIView>!
    @IBOutlet var viewsToShowLater: Array<UIView>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .m7DarkGray()
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
        
        //activity indicatior
        bookmarkBtnIndicator.startAnimating()
        bookmarkBtn.addSubview(bookmarkBtnIndicator)
        bookmarkBtnIndicator.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        checkShouldDisplayIndicator()
        
        setupSkeletonView()
        
        eventTitle.textColor = .whiteText()
        byLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        dateLabel.textColor = .whiteText()
    }

    func checkShouldDisplayIndicator() {
        if UserService.User.isLoggedIn() {
            bookmarkBtn.setImage(nil, for: .normal)
            bookmarkBtnIndicator.alpha = 1
        } else {
            bookmarkBtnIndicator.alpha = 0
        }
    }
    
    func setupSkeletonView() {
        //skeleton view
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        eventTitle.tag = 1
        for view in skeletonViews{
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 16
            } else {
                SkeletonAppearance.default.multilineHeight = 11
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
        
        for view in viewsToShowLater {
            view.alpha = 0
        }
    }
    
    override func prepareForReuse() {
        bookmarkBtn.backgroundColor = .clear
        bgImgView.image = nil
        setupSkeletonView()
        checkShouldDisplayIndicator()
        //bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
    }
    
    @IBAction func bookmarkBtnTapped(_ sender: Any) {
        delegate?.bookmarkBtnTapped(cell: self, tappedIndex: myIndexPath)
    }
}

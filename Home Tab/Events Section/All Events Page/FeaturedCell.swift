//
//  FeaturedCell.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView
import NVActivityIndicatorView

protocol FeaturedCellDelegate: class {
    func bookmarkBtnTapped(cell: FeaturedCell, tappedIndex: IndexPath)
}

class FeaturedCell: UICollectionViewCell {
    static let reuseIdentifier = "featuredCell"
    
    weak var delegate: FeaturedCellDelegate?
    var myIndexPath: IndexPath!
    var eventID: String = ""

    static let width = TrendingSection.width
    static let height: CGFloat = 93
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    @IBOutlet weak var bookmarkBtn: UIButton!
    var bookmarkBtnIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 12)), type: .lineScale)

    @IBOutlet weak var premiumBadge: UIImageView!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    @IBOutlet var skeletonViews: Array<UIView>!
    @IBOutlet var viewsToShowLater: Array<UIView>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .m7DarkGray()
        bgView.backgroundColor = .m7Charcoal()
        bgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.backgroundColor = .darkGray
        
        bookmarkBtn.backgroundColor = .clear
        bookmarkBtn.layer.cornerRadius = GlobalCornerRadius.value / 3
        bookmarkBtn.layer.shadowColor = UIColor.black.cgColor
        bookmarkBtn.layer.shadowOffset = CGSize(width: 0, height: 5)
        bookmarkBtn.layer.shadowRadius = 5
        bookmarkBtn.layer.shadowOpacity = 0.7
        
        let path = UIBezierPath(roundedRect: bgImgView.bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: GlobalCornerRadius.value, height: GlobalCornerRadius.value))

        let maskLayer = CAShapeLayer()

        maskLayer.path = path.cgPath
        bgImgView.layer.mask = maskLayer
        
        //activity indicatior
        bookmarkBtnIndicator.startAnimating()
        bookmarkBtn.addSubview(bookmarkBtnIndicator)
        bookmarkBtnIndicator.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
        }
        checkShouldDisplayIndicator()
        
        setupSkeletonViews()
        
        premiumBadge.alpha = 0
        verifiedIcon.alpha = 0
        
        eventTitle.textColor = .whiteText()
        performerLabel.textColor = .whiteText()
        bookmarkCountLabel.textColor = .whiteText()
    }
    
    func setupSkeletonViews() {
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
    
    func checkShouldDisplayIndicator() {
        if UserService.User.isLoggedIn() {
            bookmarkBtn.setImage(nil, for: .normal)
            bookmarkBtnIndicator.alpha = 1
        } else {
            bookmarkBtnIndicator.alpha = 0
        }
    }
    
    @IBAction func bookmarkBtnTapped(_ sender: Any) {
        delegate?.bookmarkBtnTapped(cell: self, tappedIndex: myIndexPath)
    }
    
    override func prepareForReuse() {
        setupSkeletonViews()
        checkShouldDisplayIndicator()
        eventTitle.text = ""
        performerLabel.text = ""
        bookmarkBtn.backgroundColor = .clear
        bgImgView.image = nil
        premiumBadge.alpha = 0
        verifiedIcon.alpha = 0
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.cellBounce(isHighlighted, view: self) }
    }
    
}

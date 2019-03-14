//
//  TrendingCell.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SkeletonView
import NVActivityIndicatorView

protocol TrendingCellDelegate {
    func bookmarkBtnTapped(cell: TrendingCell, tappedIndex: IndexPath)
}

class TrendingCell: UICollectionViewCell {

    static let reuseIdentifier = "trendingCell"
    
    var delegate: TrendingCellDelegate?
    var myIndexPath: IndexPath!
    
    private typealias `Self` = TrendingCell
    
    static let aspectRatio: CGFloat = 335.0 / 210.0 //ratio according to zeplin
    static let width = UIScreen.main.bounds.width - 40
    static var height: CGFloat = width / aspectRatio
    //static var height: CGFloat?
    
    var eventId: String = ""
    @IBOutlet weak var bgImgView: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var performerTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    @IBOutlet weak var bookmarkBtn: UIButton!
    var bookmarkBtnIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 12, height: 12)), type: .lineScale)
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    @IBOutlet var viewsToShowLater: Array<UIView>!

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
        
        //activity indicatior
        bookmarkBtnIndicator.startAnimating()
        bookmarkBtn.addSubview(bookmarkBtnIndicator)
        bookmarkBtnIndicator.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        checkShouldDisplayIndicator()
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        
        for view in skeletonViews{
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
        
        //hide some views for later
        for view in viewsToShowLater {
            view.alpha = 0
        }

        bookmarkCountLabel.textColor = .whiteText()
        eventTitle.textColor = .whiteText()
        performerTitle.textColor = .whiteText()
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
    
    override func prepareForReuse() {
        bookmarkBtn.backgroundColor = .clear
        //bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
    
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.cellBounce(isHighlighted, view: self) }
    }
    
    @IBAction func bookmarkBtnTapped(_ sender: Any) {
        delegate?.bookmarkBtnTapped(cell: self, tappedIndex: myIndexPath)
    }
}

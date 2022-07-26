//
//  EventDetailsView.swift
//  major-7-ios
//
//  Created by jason on 26/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Localize_Swift
import SkeletonView
import BouncyLayout
import NVActivityIndicatorView

protocol EventsDetailsViewDelegate: AnyObject {
    func imageCellTapped(index: Int, displacementItem: UIImageView)
    func bookmarkBtnTapped(sender: UIButton)
    func performerLabelTapped(sender: Any)
}

class EventDetailsView: UIView {
    weak var delegate: EventsDetailsViewDelegate?

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var bookmarkBtn: UIButton!
    @IBOutlet weak var bookmarkCountImg: UIImageView!
    @IBOutlet weak var bookmarkCountLabel: UILabel!
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var performerLabel: UILabel!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    @IBOutlet weak var dummyTagLabel: UILabel! //a dummy view to show skeleton view, will removeFromSuperview later
    
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var venueTitleLabel: UILabel!
    @IBOutlet weak var venueLabel: UILabel!
    
    @IBOutlet weak var descTitleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var imgCollectionView: UICollectionView!
    
    @IBOutlet weak var remarksTitleLabel: UILabel!
    @IBOutlet weak var remarksLabel: UILabel!
    
    @IBOutlet weak var webTitleLabel: UILabel!
    @IBOutlet weak var webLabel: UILabel!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    @IBOutlet var viewsToShowLater: Array<UIView>!
    
    var hashtagsArray: [String] = []
    
    var imgUrlArray: [String] = []
    
    var displacementItems: [UIImageView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EventDetailsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        verifiedIcon.alpha = 0
        
        contentView.backgroundColor = .m7DarkGray()
        contentView.layer.cornerRadius = GlobalCornerRadius.value + 4
        
        if UserService.current.isLoggedIn() {
            bookmarkBtn.setImage(nil, for: .normal)
            //loading indicatior
            loadingIndicator.startAnimating()
            bookmarkBtn.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints { (make) -> Void in
                make.center.equalToSuperview()
            }
        } else {
            bookmarkBtn.setImage(UIImage(named: "eventdetails_bookmarked_0"), for: .normal)
        }
        
        setupLabels()
        hideViews()
        
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        hashtagsCollectionView.tag = 111
        
        if let layout = hashtagsCollectionView.collectionViewLayout as? HashtagsFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        hashtagsCollectionView.contentInsetAdjustmentBehavior = .never
        hashtagsCollectionView.backgroundColor = .m7DarkGray()
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        if let layout = imgCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        imgCollectionView.backgroundColor = .m7DarkGray()
        imgCollectionView.register(UINib.init(nibName: "DetailsImageCell", bundle: nil), forCellWithReuseIdentifier: DetailsImageCell.reuseIdentifier)
        
        //hiding imgCollectionView on iPhone SE
        if UIDevice.current.type == .iPhone_5_5S_5C_SE {
            imgCollectionView.removeFromSuperview()
            remarksTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let verticalSpace = NSLayoutConstraint(item: remarksTitleLabel!, attribute: .top, relatedBy: .equal, toItem: descLabel, attribute: .bottom, multiplier: 1, constant: 20)
            
            NSLayoutConstraint.activate([verticalSpace])
        } else if UIDevice.current.type == .iPhone_6_6S_7_8_PLUS || (!UIDevice.current.hasHomeButton && UIDevice.current.type != .iPhone_6_6S_7_8) {
            descLabel.numberOfLines = 4
        }
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        titleLabel.tag = 1
        dummyTagLabel.tag = 2
        dateLabel.tag = 3
        venueLabel.tag = 4
        for view in skeletonViews{
            if view.tag == 1 || view.tag == 2 || view.tag == 3 || view.tag == 4 {
                SkeletonAppearance.default.multilineHeight = 20
            } else {
                SkeletonAppearance.default.multilineHeight = 15
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
    }
    
    @IBAction func bookmarkBtnTapped(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        delegate?.bookmarkBtnTapped(sender: sender)
    }
    
    private func setupLabels() {
        bookmarkCountLabel.textColor = .whiteText50Alpha()
        
        titleLabel.textColor = .whiteText()
        performerLabel.textColor = .whiteText75Alpha()
        
        dateTitleLabel.textColor = .topazText()
        dateTitleLabel.text = "Date | Time"
        dateLabel.textColor = .whiteText()
        
        venueTitleLabel.textColor = .topazText()
        venueTitleLabel.text = "Venue"
        venueLabel.textColor = .whiteText()
        
        descTitleLabel.textColor = .topazText()
        descTitleLabel.text = "Description"
        descLabel.textColor = .whiteText()
        
        remarksTitleLabel.textColor = .topazText()
        remarksTitleLabel.text = "Remarks"
        remarksLabel.textColor = .whiteText()
        
        webTitleLabel.textColor = .topazText()
        webTitleLabel.text = "Website"
        webLabel.textColor = .whiteText()
    }
    
    private func hideViews() {
        for view in viewsToShowLater {
            view.alpha = 0
        }
    }
    
    @IBAction func performerLabelTapped(_ sender: Any) {
        delegate?.performerLabelTapped(sender: sender)
    }
    
}

extension EventDetailsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hashtagsCollectionView{
            return hashtagsArray.count
        } else { //imgCollectionView
            return imgUrlArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hashtagsCollectionView {
            let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
            cell.hashtag.alpha = 1
            cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
            return cell
        } else { //imgCollectionView
            let cell = imgCollectionView.dequeueReusableCell(withReuseIdentifier: DetailsImageCell.reuseIdentifier, for: indexPath) as! DetailsImageCell
            cell.imgView.kf.setImage(with: URL(string: imgUrlArray[indexPath.row]), options: [.transition(.fade(0.3))])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == hashtagsCollectionView {
            let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: HashtagCell.height)
        } else { //imgCollectionView
            return CGSize(width: DetailsImageCell.width, height: DetailsImageCell.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == hashtagsCollectionView {} else {
            let cell = imgCollectionView.cellForItem(at: indexPath) as! DetailsImageCell
            delegate?.imageCellTapped(index: indexPath.row, displacementItem: cell.imgView)
        }
    }
}



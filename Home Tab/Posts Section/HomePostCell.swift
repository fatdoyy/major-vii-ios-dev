//
//  HomePostCell.swift
//  major-7-ios
//
//  Created by jason on 8/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import SkeletonView

protocol HomePostCellDelegate {
    func contentLabelTapped(indexPath: IndexPath)
}

class HomePostCell: UICollectionViewCell {
    var delegate: HomePostCellDelegate?
    var indexPath: IndexPath!
    
    static let width: CGFloat = UIScreen.main.bounds.width - 40
    static let xibWidth: CGFloat = 335
    static let xibHeight: CGFloat = 525
    static let aspectRatio: CGFloat = xibWidth / xibWidth
    static let reuseIdentifier = "homePostCell"

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var buskerIcon: UIImageView!
    @IBOutlet weak var buskerName: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    var contentLabelHeight: CGFloat!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    static let commentSectionHeight: CGFloat = 110
    @IBOutlet weak var commentSectionBg: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var showMoreBtn: UIButton!
    @IBOutlet var commentSection: Array<UIView>!
    
    @IBOutlet var skeletonViews: Array<UIView>!
    @IBOutlet var viewsToShowLater: Array<UIView>!
  
    //Constraints
    @IBOutlet var tempConstraints: Array<NSLayoutConstraint>!
    @IBOutlet var commentSectionConstraints: Array<NSLayoutConstraint>!
    @IBOutlet var imgCollectionViewConstraints: Array<NSLayoutConstraint>!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        setupSkeletonViews()
    }

}

//MARK: UI related
extension HomePostCell {
    func setupUI() {
        backgroundColor = .m7DarkGray()
        contentView.autoresizingMask = [.flexibleHeight]
        bgView.backgroundColor = UIColor(hexString: "#292b32")
        bgView.layer.cornerRadius = GlobalCornerRadius.value
        
        setupImgCollectionView()
        
        buskerIcon.clipsToBounds = true
        buskerIcon.layer.cornerRadius = 32
        buskerIcon.backgroundColor = .darkGray
        buskerIcon.contentMode = .scaleAspectFill
        
        buskerName.textColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(contentLabelTapped))
        contentLabel.isUserInteractionEnabled = true
        contentLabel.addGestureRecognizer(tap)
        //contentLabel.backgroundColor = .purpleText()
        contentLabel.numberOfLines = 2
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statsLabel.textColor = .whiteText50Alpha()
        timeLabel.textColor = .whiteText50Alpha()
        
        clapBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        clapBtn.setTitleColor(.white, for: .normal)
        clapBtn.backgroundColor = .whiteText25Alpha()
        clapBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        clapBtn.setTitle("Clap", for: .normal)
        
        commentBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        commentBtn.setTitleColor(.white, for: .normal)
        commentBtn.backgroundColor = .whiteText25Alpha()
        commentBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentBtn.setTitle("Comment", for: .normal)
        
        commentSectionBg.backgroundColor = UIColor(hexString: "#3D404A")
        userIcon.layer.cornerRadius = 15
        userIcon.contentMode = .scaleAspectFill
        username.textColor = .whiteText75Alpha()
        userComment.textColor = .white
        
        showMoreBtn.setTitleColor(.white, for: .normal)
    }
    
    func setupImgCollectionView() {
        imgCollectionView.register(UINib.init(nibName: "PostImageCell", bundle: nil), forCellWithReuseIdentifier: PostImageCell.reuseIdentifier)
        if let layout = imgCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
            layout.itemSize = CGSize(width: HomePostCell.width - 40, height: 188 /* imgCollectionView xib height */)
        }
        imgCollectionView.delegate = self
        imgCollectionView.dataSource = self
        imgCollectionView.isPagingEnabled = false
        imgCollectionView.showsHorizontalScrollIndicator = false
        imgCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        imgCollectionView.backgroundColor = UIColor(hexString: "#292b32")
    }
    
    func setupSkeletonViews() {
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        buskerName.tag = 1
        for view in skeletonViews {
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 20
            } else {
                SkeletonAppearance.default.multilineHeight = 15
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
        
        for view in viewsToShowLater {
            view.alpha = 0
        }
        
        for constraint in tempConstraints {
            constraint.isActive = false
        }
        
//        for view in commentSection {
//            view.alpha = 0
//        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.height.equalTo(42.67) //xib height
        }
        statsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentLabel.snp.bottom).offset(20)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupSkeletonViews()

        statsLabel.snp.removeConstraints()
        clapBtn.snp.removeConstraints()
        for constraint in imgCollectionViewConstraints {
            constraint.isActive = true
        }
        for constraint in commentSectionConstraints {
            constraint.isActive = true
        }
        
        buskerIcon.image = nil
        buskerName.text = ""
        contentLabel.attributedText = NSAttributedString(string: "")
        contentLabel.text = ""
    }
}

//MARK: Content Label tapped
extension HomePostCell {
    @objc func contentLabelTapped(_ sender: Any) {
        delegate?.contentLabelTapped(indexPath: indexPath)
    }
}

//MARK: UICollectionView delegate/datasource
extension HomePostCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostImageCell.reuseIdentifier, for: indexPath) as! PostImageCell
        
        cell.imgView.image = UIImage(named: "cat")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("image tapped")
    }
}

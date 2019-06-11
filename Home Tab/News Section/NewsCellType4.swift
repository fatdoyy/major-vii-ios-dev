//
//  NewsCellType4.swift
//  major-7-ios
//
//  Created by jason on 26/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Pastel
import SkeletonView

class NewsCellType4: UICollectionViewCell {
    
    static let reuseIdentifier: String = "newsCell4"
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dummyTagLabel: UILabel!
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    
    @IBOutlet var skeletonViews: Array<UILabel>!
    
    var gradientBg = PastelView()
    
    var hashtagsArray: [String] = [] {
        didSet {
            hashtagsCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray
        layer.cornerRadius = GlobalCornerRadius.value
        
        hashtagsCollectionView.showsHorizontalScrollIndicator = false
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        
        if let layout = hashtagsCollectionView.collectionViewLayout as? HashtagsFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        hashtagsCollectionView.contentInsetAdjustmentBehavior = .always
        hashtagsCollectionView.backgroundColor = .clear
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        
        // Custom Direction
        gradientBg.startPastelPoint = .bottomLeft
        gradientBg.endPastelPoint = .topRight
        
        // Custom Duration
        gradientBg.animationDuration = 2.5
        
        // Custom Color
        gradientBg.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        //gradientBg.startAnimation()
        insertSubview(gradientBg, at: 0)
        gradientBg.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType3.width)
            make.height.equalTo(NewsCellType3.height)
        }
        //gradientBg.isHidden = true
        
        //limiting the number of lines on iPhone SE because the screen is too small and will cause layout problems
        newsTitle.numberOfLines = UIDevice.current.type == .iPhone_5_5S_5C_SE ? 1 : 2
        
        let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
        newsTitle.tag = 1
        dummyTagLabel.tag = 2
        for view in skeletonViews{
            if view.tag == 1 {
                SkeletonAppearance.default.multilineHeight = 20
            } else {
                SkeletonAppearance.default.multilineHeight = 15
            }
            view.isSkeletonable = true
            view.showAnimatedGradientSkeleton(animation: animation)
        }
        
        newsTitle.lineBreakMode = .byTruncatingTail
        newsTitle.lastLineFillPercent = 70
        newsTitle.textColor = .whiteText()
        
        subTitle.textColor = .whiteText()
        
        timeLabel.textColor = .whiteText()
        
        countLabel.textColor = .whiteText()
        
        viewsLabel.textColor = .whiteText()
        viewsLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.cellBounce(isHighlighted, view: self) }
    }
    
}

extension NewsCellType4: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = hashtagsArray.isEmpty ? 0 : hashtagsArray.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
        cell.backgroundColor = .clear
        cell.hashtag.alpha = 1
        cell.hashtag.text = hashtagsArray.isEmpty ? "" : "#\(hashtagsArray[indexPath.row])"
        cell.hashtag.textColor = .white
        //cell.bgView.backgroundColor = .lightPurple()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if !hashtagsArray.isEmpty {
            let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: HashtagCell.height)
        } else {
            return CGSize()
        }
    }
}

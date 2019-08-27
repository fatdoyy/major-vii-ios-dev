//
//  NewsCellType3.swift
//  major-7-ios
//
//  Created by jason on 25/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import MarqueeLabel

class NewsCellType3: UICollectionViewCell {

    static let reuseIdentifier: String = "newsCell3"
    
    private typealias `Self` = NewsCellType3
    
    static let aspectRatio: CGFloat = 335.0 / 203.0 //template 3 ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var subTitle: MarqueeLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    
    @IBOutlet var newsTitleTopConstraint: NSLayoutConstraint!
    
    var hashtagsArray = [String]() {
        didSet {
            hashtagsCollectionView.reloadData()
        }
    }
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .m7DarkGray()
        
        hashtagsCollectionView.showsHorizontalScrollIndicator = false
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        
        if let layout = hashtagsCollectionView.collectionViewLayout as? HashtagsFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        hashtagsCollectionView.contentInsetAdjustmentBehavior = .never
        hashtagsCollectionView.backgroundColor = .clear
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        
        newsTitle.lineBreakMode = .byTruncatingTail
        
        //limiting the number of lines on iPhone SE because the screen is too small and will cause layout problems
        newsTitle.numberOfLines = UIDevice.current.type == .iPhone_5_5S_5C_SE ? 1 : 2
        
        newsTitle.textColor = .whiteText()
        
        subTitle.textColor = .whiteText()
        
        dateLabel.textColor = .lightGrayText()
        
        countLabel.text = "2,636"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        viewsLabel.isHidden = true
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: Self.width, height: Self.height)
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(Self.width)
            make.height.equalTo(Self.height)
        }
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor(hexString: "333333").withAlphaComponent(0.75)
        overlayView.layer.cornerRadius = GlobalCornerRadius.value
        overlayView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(Self.width)
            make.height.equalTo(Self.height)
        }
        sendSubviewToBack(bgImgView)
        insertSubview(overlayView, aboveSubview: bgImgView)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bgImgView.image = nil
        newsTitle.snp.removeConstraints()
        newsTitleTopConstraint.isActive = true
        hashtagsArray.removeAll()
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.cellBounce(isHighlighted, view: self) }
    }
}

//MARK: - UICollectionView delegate
extension NewsCellType3: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        cell.bgView.backgroundColor = .darkPurple()
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

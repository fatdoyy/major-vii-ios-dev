//
//  NewsCell.swift
//  major-7-ios
//
//  Created by jason on 24/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SnapKit

class NewsCellType1: UICollectionViewCell {
    
    static let reuseIdentifier: String = "newsCell1"
    
    static let aspectRatio: CGFloat = 335.0 / 258.0 //according to zeplin
    static let width = UIScreen.main.bounds.width - 40 // minus leading (20pt) and trailing (20pt) space
    static let height = width / aspectRatio
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var imageOverlay: ImageOverlay!
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    
    var hashtagsArray: [String] = [] {
        didSet {
            print(hashtagsArray)
            hashtagsCollectionView.reloadData()
        }
    }
    
    var bgImgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()

        hashtagsCollectionView.showsHorizontalScrollIndicator = false
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        hashtagsCollectionView.tag = 111
        
        if let layout = hashtagsCollectionView.collectionViewLayout as? HashtagsFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        hashtagsCollectionView.contentInsetAdjustmentBehavior = .always
        hashtagsCollectionView.backgroundColor = .clear
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        
        imageOverlay.clipsToBounds = true
        imageOverlay.layer.cornerRadius = GlobalCornerRadius.value
        
        //newsTitle.lineBreakMode = .byWordWrapping
        newsTitle.numberOfLines = 0
        newsTitle.textColor = .whiteText()
        
        timeLabel.text = "1 month ago"
        timeLabel.textColor = .whiteText()
        
        countLabel.text = "12,843"
        countLabel.textColor = .whiteText()
        
        viewsLabel.text = "views"
        viewsLabel.textColor = .whiteText()
        
        bgImgView = UIImageView()
        bgImgView.frame = CGRect(x: 0, y: 0, width: NewsCellType1.width, height: NewsCellType1.height)
        bgImgView.backgroundColor = .gray
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.layer.cornerRadius = GlobalCornerRadius.value
        bgImgView.clipsToBounds = true
        addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(NewsCellType1.width)
            make.height.equalTo(NewsCellType1.height)
        }
        sendSubviewToBack(bgImgView)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bgImgView.image = nil
    }
    
    override var isHighlighted: Bool {
        didSet { Animations.cellBounce(isHighlighted, view: self) }
    }
}

extension NewsCellType1: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
        cell.backgroundColor = .clear
        cell.hashtag.alpha = 1
        cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
        cell.hashtag.textColor = .white
        cell.bgView.backgroundColor = .lightPurple()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
        return CGSize(width: size.width + 32, height: HashtagCell.height)
    }
}

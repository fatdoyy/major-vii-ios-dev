//
//  HomePostCell.swift
//  major-7-ios
//
//  Created by jason on 8/7/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class HomePostCell: UICollectionViewCell {

    static let width: CGFloat = UIScreen.main.bounds.width - 40
    static let height: CGFloat = 471
    static let reuseIdentifier = "homePostCell"
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var buskerIcon: UIImageView!
    @IBOutlet weak var buskerName: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var statsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var clapBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    
    @IBOutlet weak var commentSectionBg: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userComment: UILabel!
    @IBOutlet weak var showMoreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .darkGray()
        bgView.backgroundColor = UIColor(hexString: "#292b32")
        bgView.layer.cornerRadius = GlobalCornerRadius.value
        
        buskerIcon.clipsToBounds = true
        buskerIcon.layer.cornerRadius = 32
        buskerIcon.backgroundColor = .darkGray
        
        buskerName.textColor = .white
        buskerName.backgroundColor = .yellow
        
        contentLabel.numberOfLines = 0
        contentLabel.backgroundColor = .red
        contentLabel.lineBreakMode = .byTruncatingTail
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

//        imgCollectionView.delegate = self
//        imgCollectionView.dataSource = self
        
        statsLabel.textColor = .whiteText50Alpha()
        timeLabel.textColor = .whiteText50Alpha()
        
        clapBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        clapBtn.setTitleColor(.white, for: .normal)
        clapBtn.backgroundColor = .whiteText25Alpha()
        
        commentBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        commentBtn.setTitleColor(.white, for: .normal)
        commentBtn.backgroundColor = .whiteText25Alpha()
        
        commentSectionBg.backgroundColor = .darkGray
        userIcon.layer.cornerRadius = 15
        username.textColor = .whiteText75Alpha()
        userComment.textColor = .white
        
        showMoreBtn.setTitleColor(.white, for: .normal)
    }

}


////MARK: UICollectionView delegate/datasource
//extension HomePostCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 2
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
//
//
//}

//
//  FollowingSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout

protocol FollowingSectionDelegate{
    func followingCellTapped()
}

class FollowingSection: UICollectionViewCell {

    static let reuseIdentifier = "followingSection"
    
    var delegate: FollowingSectionDelegate?
    
    static let height: CGFloat = 238
    
    @IBOutlet weak var followingSectionTitle: UILabel!
    @IBOutlet weak var followingSectionCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        followingSectionTitle.textColor = .whiteText()
        followingSectionTitle.text = "Your Followings"
        
        if let layout = followingSectionCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        followingSectionCollectionView.dataSource = self
        followingSectionCollectionView.delegate = self
        
        followingSectionCollectionView.showsVerticalScrollIndicator = false
        followingSectionCollectionView.showsHorizontalScrollIndicator = false
        
        followingSectionCollectionView.backgroundColor = .darkGray()
        followingSectionCollectionView.register(UINib.init(nibName: "FollowingCell", bundle: nil), forCellWithReuseIdentifier: FollowingCell.reuseIdentifier)
    }
    
}

extension FollowingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = followingSectionCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingCell.reuseIdentifier, for: indexPath) as! FollowingCell
        cell.delegate = self
        cell.eventTitle.text = "天星碼頭"
        cell.dateLabel.text = "明天"
        cell.performerLabel.text = "Billy Fung"
        cell.bgImgView.image = UIImage(named: "cat")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: FollowingCell.width, height: FollowingCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.followingCellTapped()
    }
    
}

extension FollowingSection: FollowingCellDelegate {
    func bookmarkBtnTapped() {
        print("tapped")
    }
}

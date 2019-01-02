//
//  BookmarkSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout

protocol BookmarkSectionDelegate{
    func bookmarkCellTapped()
}

class BookmarkSection: UICollectionViewCell {

    static let reuseIdentifier = "bookmarkSection"
    
    var delegate: BookmarkSectionDelegate?
    
    static let height: CGFloat = 247
    
    @IBOutlet weak var bookmarkSectionTitle: UILabel!
    @IBOutlet weak var bookmarksCountLabel: UILabel!
    @IBOutlet weak var bookmarksCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bookmarkSectionTitle.textColor = .whiteText()
        bookmarkSectionTitle.text = "Your Bookmarks"
        
        bookmarksCountLabel.textColor = .purpleText()
        bookmarksCountLabel.text = "4 Events"
        
        if let layout = bookmarksCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        bookmarksCollectionView.dataSource = self
        bookmarksCollectionView.delegate = self
        
        bookmarksCollectionView.showsVerticalScrollIndicator = false
        bookmarksCollectionView.showsHorizontalScrollIndicator = false
        
        bookmarksCollectionView.backgroundColor = .darkGray()
        bookmarksCollectionView.register(UINib.init(nibName: "BookmarkCell", bundle: nil), forCellWithReuseIdentifier: BookmarkCell.reuseIdentifier)
    }

}

extension BookmarkSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookmarksCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkCell.reuseIdentifier, for: indexPath) as! BookmarkCell
        cell.delegate = self
        cell.eventTitle.text = "天星碼頭"
        cell.dateLabel.text = "明天"
        cell.performerLabel.text = "Billy Fung"
        cell.bgImgView.image = UIImage(named: "cat")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: BookmarkCell.width, height: BookmarkCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.bookmarkCellTapped()
    }
}

extension BookmarkSection: BookmarkCellDelegate {
    func bookmarkBtnTapped() {
        print("tapped")
    }
}

//
//  BookmarkSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import NVActivityIndicatorView

protocol BookmarkSectionDelegate{
    func bookmarkedCellTapped()
}

class BookmarkedSection: UICollectionViewCell {

    static let reuseIdentifier = "bookmarkSection"
    
    var delegate: BookmarkSectionDelegate?
        
    static let height: CGFloat = 247
    
    @IBOutlet weak var bookmarkSectionTitle: UILabel!
    @IBOutlet weak var bookmarksCountLabel: UILabel!
    @IBOutlet weak var bookmarksCollectionView: UICollectionView!
    
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            bookmarksCollectionView.reloadData()
        }
    }
    
    var reloadIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)), type: .lineScale)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: .refreshBookmarkedSection, object: nil)
        
        bookmarkSectionTitle.textColor = .whiteText()
        bookmarkSectionTitle.text = "Your Bookmarks"
        
        bookmarksCountLabel.textColor = .purpleText()
        bookmarksCountLabel.text = "4 Events"
        
        if let layout = bookmarksCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        if !UserService.User.isLoggedIn() {
            bookmarksCollectionView.alpha = 0
        }
        
        bookmarksCollectionView.dataSource = self
        bookmarksCollectionView.delegate = self
        
        bookmarksCollectionView.showsVerticalScrollIndicator = false
        bookmarksCollectionView.showsHorizontalScrollIndicator = false
        
        bookmarksCollectionView.backgroundColor = .darkGray()
        bookmarksCollectionView.register(UINib.init(nibName: "BookmarkedCell", bundle: nil), forCellWithReuseIdentifier: BookmarkedCell.reuseIdentifier)
        
        reloadIndicator.alpha = 0
        addSubview(reloadIndicator)
        reloadIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(bookmarksCollectionView.snp.centerX)
            make.centerY.equalTo(bookmarksCollectionView.snp.centerY)
        }
        
        getBookmarkedEvents()
    }

    private func getBookmarkedEvents() {
        EventService.getBookmarkedEvents().done { response in
            self.bookmarkedEvents = response.bookmarkedEventsList
            print("bookmarked events list count: \(response.bookmarkedEventsList.count)")
            }.ensure {
                if self.reloadIndicator.alpha != 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.reloadIndicator.alpha = 0
                        self.bookmarksCollectionView.alpha = 1
                    }
                    self.reloadIndicator.stopAnimating()
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    @objc private func reloadCollectionView() {
        reloadIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.bookmarksCollectionView.alpha = 0
            self.reloadIndicator.alpha = 1
        }
        
        getBookmarkedEvents()
        print("1234567")
        bookmarksCollectionView.reloadData()
    }
}

extension BookmarkedSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if UserService.User.isLoggedIn() && !bookmarkedEvents.isEmpty {
            return bookmarkedEvents.count
        } else {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookmarksCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedCell.reuseIdentifier, for: indexPath) as! BookmarkedCell
        cell.delegate = self
        cell.eventTitle.text = "天星碼頭"
        cell.dateLabel.text = "明天"
        cell.performerLabel.text = "Billy Fung"
        cell.bgImgView.image = UIImage(named: "cat")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: BookmarkedCell.width, height: BookmarkedCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.bookmarkedCellTapped()
    }
}

extension BookmarkedSection: BookmarkedCellDelegate {
    func bookmarkBtnTapped() {
        print("tapped")
    }
}

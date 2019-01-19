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
    
    var tredingSectionIndexDict: [Int: String] = [:] //to refresh TrendingCell bookmakrBtn state
    
    var bookmarkedEventArray: [Int] = [] //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            bookmarksCollectionView.reloadData()
        }
    }
    
    var reloadIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)), type: .lineScale)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBookmarkedSection(_:)), name: .refreshBookmarkedSection, object: nil)
        
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
    
    @objc private func refreshBookmarkedSection(_ notification: Notification) {
        reloadIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            self.bookmarksCollectionView.alpha = 0
            self.reloadIndicator.alpha = 1
        }
        getBookmarkedEvents()
        
        if let data = notification.userInfo {
            if let keyToAdd = data["key_to_add"] as? Int, let id = data["id"] as? String {
                self.tredingSectionIndexDict[keyToAdd] = id
                print("recived keyToAdd: \(keyToAdd), tredingSectionIndexArray: \(self.tredingSectionIndexDict)")
            } else if let keyToRemove = data["key_to_remove"] as? Int, let _ = data["id"] as? String {
                self.tredingSectionIndexDict.removeValue(forKey: keyToRemove)
                print("recived keyToRemove: \(keyToRemove), tredingSectionIndexArray: \(self.tredingSectionIndexDict)")
            }
        }
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
        if !bookmarkedEvents.isEmpty {
            if let event = bookmarkedEvents[indexPath.row].targetEvent {
                cell.delegate = self
                cell.myIndexPath = indexPath
                cell.eventTitle.text = event.title
                cell.dateLabel.text = event.dateTime
                cell.performerLabel.text = event.organizerProfile?.name
                cell.bookmarkBtn.backgroundColor = .mintGreen()
                if let url = URL(string: event.images[0].secureUrl!) {
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.75))])
                }
            }
        }
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
    func bookmarkBtnTapped(cell: BookmarkedCell, tappedIndex: IndexPath) {
        if let eventId = bookmarkedEvents[tappedIndex.row].targetEvent?.id {
            if (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //do bookmark action
                HapticFeedback.createImpact(style: .heavy)
                cell.bookmarkBtn.isUserInteractionEnabled = false

                //animate button state
                cell.bookmarkBtnIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarkBtnIndicator.alpha = 1
                }

                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.bookmarkBtn.setImage(nil, for: .normal)
                }, completion: nil)

                //create bookmark action
                EventService.createBookmark(eventId: eventId).done { _ in
                    print("Event with ID (\(eventId)) bookmarked")
                    }.ensure {
                        self.bookmarkedEventArray.append(tappedIndex.row) //the cell is now hold by this array and will not have cell reuse issues
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .mintGreen()
                            cell.bookmarkBtnIndicator.alpha = 0
                        }

                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)

                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil) //reload collection view in BookmarkedSection
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
                
            } else { //remove bookmark
                print(tappedIndex.row)
                HapticFeedback.createImpact(style: .light)
                cell.bookmarkBtn.isUserInteractionEnabled = false

                //animate button state
                cell.bookmarkBtnIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarkBtnIndicator.alpha = 1
                }

                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.bookmarkBtn.setImage(nil, for: .normal)
                }, completion: nil)

                //remove bookmark action
                EventService.removeBookmark(eventId: eventId).done { response in
                    //print(response)
                    }.ensure {
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .clear
                            cell.bookmarkBtnIndicator.alpha = 0
                        }

                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)

                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        
//                        if self.tredingSectionIndexArray.isEmpty { //also reload collection view in TrendingSection if cell is visible
//                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["id": eventId])
//                        } else {
//
//                        }
                        
                        NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["key_to_remove": Array(self.tredingSectionIndexDict)[tappedIndex.row].key, "id": eventId])
                        print("Sending index \(Array(self.tredingSectionIndexDict)[tappedIndex.row].key) from BookmarkedSection to TrendingSection")
                        self.tredingSectionIndexDict.removeValue(forKey: tappedIndex.row)
                        
                        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil) //reload collection view in this view
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
            }

        } else {
            print("Can't get bookamrk section event id")
        }
        
    }
}

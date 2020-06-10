//
//  TrendingSection.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SwiftMessages

protocol TrendingSectionDelegate: class {
    func trendingCellTapped(eventID: String)
    func showLoginVC()
}

class TrendingSection: UICollectionViewCell {
    static let reuseIdentifier = "trendingSection"
    
    weak var delegate: TrendingSectionDelegate?
    
    static let aspectRatio: CGFloat = 335.0 / 292.0 //ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var trendingSectionLabel: UILabel!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    var bookmarkedEventIDArray = [String]() //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    var trendingEvents = [Event]() {
        didSet {
            trendingCollectionView.reloadData()
        }
    }
    var boolArr = [Int]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.setObserver(self, selector: #selector(showLoginVC), name: .showLoginVC, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshTrendingSection), name: .refreshTrendingSection, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshTrendingSectionCell(_:)), name: .refreshTrendingSectionCell, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(removeAllObservers), name: .removeTrendingSectionObservers, object: nil)

        setupUI()
    }
    
    //remove observers
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UI related
extension TrendingSection {
    private func setupUI() {
        trendingSectionLabel.textColor = .whiteText()
        trendingSectionLabel.text = "Trending"
        
        if let layout = trendingCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: TrendingSectionCell.width, height: TrendingSectionCell.height)
            layout.minimumLineSpacing = 10
        }
        
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
        trendingCollectionView.showsVerticalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.isPagingEnabled = false
        
        trendingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        trendingCollectionView.backgroundColor = .m7DarkGray()
        trendingCollectionView.register(UINib.init(nibName: "TrendingSectionCell", bundle: nil), forCellWithReuseIdentifier: TrendingSectionCell.reuseIdentifier)
        
        getTrendingEvents()
    }

    @objc func showLoginVC() {
        delegate?.showLoginVC()
    }
    
    private func addBookmarkAnimation(cell: TrendingSectionCell) {
        cell.bookmarkBtn.isUserInteractionEnabled = false
        
        cell.bookmarkBtnIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            cell.bookmarkBtnIndicator.alpha = 1
        }
        
        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            cell.bookmarkBtn.setImage(nil, for: .normal)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            UIView.animate(withDuration: 0.2) {
                cell.bookmarkBtn.backgroundColor = .mintGreen()
                cell.bookmarkBtnIndicator.alpha = 0
            }
            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
            }, completion: nil)
            cell.bookmarkBtn.isUserInteractionEnabled = true
        }
    }
    
    private func removeBookmarkAnimation(cell: TrendingSectionCell) {
        cell.bookmarkBtn.isUserInteractionEnabled = false
        
        cell.bookmarkBtnIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            cell.bookmarkBtnIndicator.alpha = 1
        }
        
        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
            cell.bookmarkBtn.setImage(nil, for: .normal)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            UIView.animate(withDuration: 0.2) {
                cell.bookmarkBtn.backgroundColor = .clear
                cell.bookmarkBtnIndicator.alpha = 0
            }
            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
            }, completion: nil)
            cell.bookmarkBtn.isUserInteractionEnabled = true
        }
    }
}

//MARK: - UICollectionView Data Source
extension TrendingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = trendingEvents.isEmpty ? 2 : trendingEvents.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingSectionCell.reuseIdentifier, for: indexPath) as! TrendingSectionCell
        
        if !trendingEvents.isEmpty {
            cell.delegate = self
            cell.myIndexPath = indexPath
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            for view in cell.viewsToShowLater { //show hidden view
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1.0
                }
            }
            
            if let imgUrl = URL(string: (trendingEvents[indexPath.row].images.first?.url)!) {
                cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.2))])
            }
            
            if let id = trendingEvents[indexPath.row].id {
                cell.eventID = id
            }
            
            cell.eventTitle.text = trendingEvents[indexPath.row].title
            cell.performerTitle.text = trendingEvents[indexPath.row].organizerProfile?.name
            
            UIView.animate(withDuration: 0.4) {
                cell.premiumBadge.alpha = self.boolArr[indexPath.row] == 1 ? 1 : 0
            }
            UIView.animate(withDuration: 0.4) {
                cell.verifiedIcon.alpha = self.trendingEvents[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
            }
            
            if let eventDate = trendingEvents[indexPath.row].dateTime?.toDate(), let currentDate = Date().toISO().toDate() {
                let difference = DateTimeHelper.getEventInterval(from: currentDate, to: eventDate)
                cell.dateLabel.text = difference
            }
            
            cell.bookmarkBtn.backgroundColor = .clear
            
            //detemine bookmarkBtn bg color
            checkBookmarkBtnState(cell: cell, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.trendingCellTapped(eventID: trendingEvents[indexPath.row].id ?? "")
    }
}

//MARK: - API Calls | Bookmark action | Bookmark btn state | Trending cell delegate
extension TrendingSection: TrendingSectionCellDelegate {
    private func getTrendingEvents() { //get trending events list
        trendingCollectionView.isUserInteractionEnabled = false
        EventService.getTrendingEvents().done { response in
            self.trendingEvents = response.list.reversed()
            for _ in 0 ..< self.trendingEvents.count {
                self.boolArr.append(Int.random(in: 0 ... 1))
            }
            }.ensure {
                self.trendingCollectionView.isUserInteractionEnabled = true

                NotificationCenter.default.post(name: .eventListEndRefreshing, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    //pull to refrsh
    @objc func refreshTrendingSection() {
        //first clear data model
        bookmarkedEventIDArray.removeAll()
        trendingEvents.removeAll()
        trendingCollectionView.setContentOffset(CGPoint(x: -20, y: 0), animated: true)
        trendingCollectionView.reloadData()
        
        getTrendingEvents()
    }
    
    func checkBookmarkBtnState(cell: TrendingSectionCell, indexPath: IndexPath) {
        if UserService.current.isLoggedIn() {
            if let eventID = trendingEvents[indexPath.row].id {
                if !bookmarkedEventIDArray.contains(eventID) {
                    /// Check if local array is holding this bookmarked cell
                    /// NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server
                    
                    UserService.getBookmarkedEvents().done { response in
                        if !response.list.isEmpty {
                            for event in response.list {
                                //check if bookmarked list contains id
                                let isBookmarked = event.targetEvent?.id == eventID
                                if isBookmarked {
                                    self.bookmarkedEventIDArray.append(eventID) //add this cell to local array to avoid reuse
                                    
                                    //animate button state
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                    
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                                    }
                                    
                                } else { //not bookmarked
                                    //animate button state to default
                                    UIView.animate(withDuration: 0.2) {
                                        cell.bookmarkBtnIndicator.alpha = 0
                                    }
                                    
                                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                    }, completion: nil)
                                }
                            }
                        } else { //logged in user have no bookmarked events
                            //animate button state to default
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                        }
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                    
                } else { //this cell is bookmarked and held by local array, will bypass check from api
                    //animate button state
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                        cell.bookmarkBtnIndicator.alpha = 0
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                    }, completion: nil)
                }
            }
        }
    }
    
    //refresh bookmarkBtn state
    @objc private func refreshTrendingSectionCell(_ notification: Notification) {
        let visibleCells = trendingCollectionView.visibleCells as! [TrendingSectionCell]
        if let event = notification.userInfo {
            if let addID = event["add_id"] as? String {
                bookmarkedEventIDArray.remove(object: addID) //add id from local array
                
                for cell in visibleCells {
                    if cell.eventID == addID { //add bookmark
                        addBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let removeID = event["remove_id"] as? String {  //Callback from Bookmarked Section
                bookmarkedEventIDArray.remove(object: removeID) //remove id from local array
                
                for cell in visibleCells {
                    if cell.eventID == removeID { //remove bookmark
                        removeBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let checkID = event["check_id"] as? String { //Callback from Event Details
                UserService.getBookmarkedEvents().done { response in
                    if !response.list.isEmpty {
                        if response.list.contains(where: { $0.targetEvent?.id == checkID }) { //check visible cell is bookmarked or not
                            for cell in visibleCells { //check bookmarked list contains id
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //add bookmark
                                    if !self.bookmarkedEventIDArray.contains(checkID) {
                                        self.bookmarkedEventIDArray.append(checkID)
                                        print("Callback from details array \(self.bookmarkedEventIDArray)")
                                    }
                                    self.addBookmarkAnimation(cell: cell)
                                }
                            }
                            
                        } else { //checkID is not in bookmarked list
                            if self.bookmarkedEventIDArray.contains(checkID) {
                                self.bookmarkedEventIDArray.remove(object: checkID)
                            }
                            
                            for cell in visibleCells {
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.mintGreen()))! {
                                    self.removeBookmarkAnimation(cell: cell)
                                }
                            }
                        }
                        
                    } else { //bookmarked list is empty, remove id from array
                        if self.bookmarkedEventIDArray.contains(checkID) {
                            self.bookmarkedEventIDArray.remove(object: checkID)
                        }
                        
                        for cell in visibleCells {
                            self.removeBookmarkAnimation(cell: cell)
                        }
                    }
                    }.ensure { UIApplication.shared.isNetworkActivityIndicatorVisible = false }.catch { error in }
                
            }
        }
    }
    
    //bookmarkBtn tapped
    func bookmarkBtnTapped(cell: TrendingSectionCell, tappedIndex: IndexPath) {
        if UserService.current.isLoggedIn() {
            if let eventID = self.trendingEvents[tappedIndex.row].id {
                if (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //do bookmark action
                    HapticFeedback.createImpact(style: .light)
                    cell.bookmarkBtn.isUserInteractionEnabled = false
                    
                    //animate button state
                    UIView.animate(withDuration: 0.2) {
                        cell.bookmarkBtnIndicator.alpha = 1
                    }
                    
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(nil, for: .normal)
                    }, completion: nil)
                    
                    //create bookmark action
                    EventService.createBookmark(eventID: eventID).done { _ in
                        print("Event with ID (\(eventID)) bookmarked")
                        }.ensure {
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtn.backgroundColor = .mintGreen()
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                            
                            cell.bookmarkBtn.isUserInteractionEnabled = true
                            if !self.bookmarkedEventIDArray.contains(eventID) {
                                self.bookmarkedEventIDArray.append(eventID)
                            }
                            
                            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["add_id": eventID]) //refresh bookmarkBtn state in FollowingSection
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["add_id": eventID]) //reload collection view in BookmarkedSection
                            NotificationCenter.default.post(name: .refreshFeaturedSectionCell, object: nil, userInfo: ["add_id": eventID]) //refresh bookmarkBtn state in FeaturedSection
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                    
                } else { //remove bookmark
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
                    EventService.removeBookmark(eventID: eventID).done { response in
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .clear
                            cell.bookmarkBtnIndicator.alpha = 0
                        }
                        
                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)
                        
                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        
                        if let index = self.bookmarkedEventIDArray.firstIndex(of: eventID) {
                            self.bookmarkedEventIDArray.remove(at: index)
                            print("Trending Section array: \(self.bookmarkedEventIDArray)\n")
                        }
                        }.ensure {
                            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in FollowingSection
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["remove_id": eventID]) //reload collection view in BookmarkedSection
                            NotificationCenter.default.post(name: .refreshFeaturedSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in FeaturedSection
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                }
                
            } else {
                print("Can't get trending section event id")
            }
            
        } else { // not logged in
            SwiftMessages.show(view: InAppNotifications.loginWarning())
        }
        
    }
    
}

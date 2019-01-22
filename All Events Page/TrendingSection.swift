//
//  TrendingSection.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

protocol TrendingSectionDelegate{
    func trendingCellTapped(eventId: String)
    //func trendingCellBookmarkBtnTapped(section: TrendingSection, cell: TrendingCell, tappedIndex: IndexPath)
}

class TrendingSection: UICollectionViewCell {
    
    static let reuseIdentifier = "trendingSection"
    
    var delegate: TrendingSectionDelegate?

    static let aspectRatio: CGFloat = 335.0 / 297.0 //ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var trendingSectionLabel: UILabel!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    var bookmarkedEventArray: [String] = [] { //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
        didSet{
            
        }
    }
    
    var trendingEvents: [Event] = [] {
        didSet {
            trendingCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.setObserver(self, selector: #selector(refreshTrendingSectionCell(_:)), name: .refreshTrendingSectionCell, object: nil)
        
        trendingSectionLabel.textColor = .whiteText()
        trendingSectionLabel.text = "Trending"
        
        if let layout = trendingCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: TrendingCell.width, height: TrendingCell.height)
            layout.minimumLineSpacing = 10
        }
        
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
        trendingCollectionView.showsVerticalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.isPagingEnabled = false
        
        trendingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        trendingCollectionView.backgroundColor = .darkGray()
        trendingCollectionView.register(UINib.init(nibName: "TrendingCell", bundle: nil), forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
        
        //getTrendingEvents()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //fix big/small screen ratio issue
        //trendingCollectionView.frame.size.height = TrendingCell.height
    }
    
    //get trending events list
    func getTrendingEvents(){
        EventService.getTrendingEvents().done { response in
            self.trendingEvents = response.eventsList
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    //refresh bookmarkBtn state
    @objc private func refreshTrendingSectionCell(_ notification: Notification) {
        let visibleCells = trendingCollectionView.visibleCells as! [TrendingCell]
        if let event = notification.userInfo {
            if let removeId = event["remove_id"] as? String {
                    self.bookmarkedEventArray.remove(object: removeId) //remove id from local array
                    print(self.bookmarkedEventArray)
                
                for cell in visibleCells {
                    if cell.eventId == removeId { //remove bookmark
                        cell.bookmarkBtn.isUserInteractionEnabled = false
                        
                        //animate button state
                        cell.bookmarkBtnIndicator.startAnimating()
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtnIndicator.alpha = 1
                        }
                        
                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(nil, for: .normal)
                        }, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
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
            }
        }
    }
    
    //remove observers
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UICollectionView Data Source
extension TrendingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = trendingEvents.isEmpty ? 2 : trendingEvents.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier, for: indexPath) as! TrendingCell
        
        if !trendingEvents.isEmpty {
            cell.delegate = self
            cell.myIndexPath = indexPath
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            for view in cell.viewsToShowLater { //show hidden view
                UIView.animate(withDuration: 0.75){
                    view.alpha = 1.0
                }
            }
            
            if let imgUrl = URL(string: (trendingEvents[indexPath.row].images.first?.secureUrl)!) {
                cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.75))])
            }
            
            if let id = trendingEvents[indexPath.row].id {
                cell.eventId = id
            }
            
            cell.eventTitle.text = trendingEvents[indexPath.row].title
            cell.performerLabel.text = trendingEvents[indexPath.row].organizerProfile?.name
            cell.dateLabel.text = trendingEvents[indexPath.row].dateTime
            cell.bookmarkBtn.backgroundColor = .clear
            
            //detemine bookmarkBtn bg color
            if UserService.User.isLoggedIn() {
                if let eventId = trendingEvents[indexPath.row].id {
                    if !bookmarkedEventArray.contains(eventId) {
                        /* Check if local array is holding this bookmarked cell
                         NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server */
                        
                        EventService.getBookmarkedEvents().done { response in
                            if !response.bookmarkedEventsList.isEmpty {
                                for event in response.bookmarkedEventsList {
                                    //check if bookmarked list contains id
                                    let isBookmarked = event.targetEvent?.id == self.trendingEvents[indexPath.row].id
                                    if isBookmarked {
                                        self.bookmarkedEventArray.append(eventId) //add this cell to local array to avoid reuse
                                        print(self.bookmarkedEventArray)
                                        
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.trendingCellTapped(eventId: trendingEvents[indexPath.row].id ?? "")
    }
}

//Bookmark action
extension TrendingSection: TrendingCellDelegate {
    func bookmarkBtnTapped(cell: TrendingCell, tappedIndex: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventId = self.trendingEvents[tappedIndex.row].id {
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
                    EventService.createBookmark(eventId: eventId).done { _ in
                        print("Event with ID (\(eventId)) bookmarked")
                        }.ensure {
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtn.backgroundColor = .mintGreen()
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                            
                            cell.bookmarkBtn.isUserInteractionEnabled = true
                            self.bookmarkedEventArray.append(eventId)
                            print("Trending Section array: \(self.bookmarkedEventArray)\n")
                            
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["add_id": eventId]) //reload collection view in BookmarkedSection
                            
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
                    EventService.removeBookmark(eventId: eventId).done { response in
                        print(response)
                        }.ensure {
                            
                            UIView.animate(withDuration: 0.2) {
                                cell.bookmarkBtn.backgroundColor = .clear
                                cell.bookmarkBtnIndicator.alpha = 0
                            }
                            
                            UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                            }, completion: nil)
                            
                            cell.bookmarkBtn.isUserInteractionEnabled = true
                            
                            if let index = self.bookmarkedEventArray.index(of: eventId) {
                                self.bookmarkedEventArray.remove(at: index)
                                print("Trending Section array: \(self.bookmarkedEventArray)\n")
                            }
                            
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["remove_id": eventId]) //reload collection view in BookmarkedSection
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                }
                
            } else {
                print("Can't get trending section event id")
            }
            
        } else { // not logged in
            print("please login first")
        }
        
    }
    
}

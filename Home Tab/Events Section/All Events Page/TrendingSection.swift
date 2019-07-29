//
//  TrendingSection.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SwiftMessages

protocol TrendingSectionDelegate{
    func trendingCellTapped(eventID: String)
    func showLoginVC()
}

class TrendingSection: UICollectionViewCell {
    
    static let reuseIdentifier = "trendingSection"
    
    var delegate: TrendingSectionDelegate?
    
    static let aspectRatio: CGFloat = 335.0 / 292.0 //ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var trendingSectionLabel: UILabel!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    var loginMsgView = MessageView.viewFromNib(layout: .cardView)
    
    var bookmarkedEventArray: [String] = [] //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    
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
        
        trendingCollectionView.backgroundColor = .m7DarkGray()
        trendingCollectionView.register(UINib.init(nibName: "TrendingCell", bundle: nil), forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
        
        //getTrendingEvents()
        setupLoginWarning()
    }
    
    private func setupLoginWarning() {

        // Theme message elements with the warning style.
        loginMsgView.configureTheme(.warning)
        
        // Add a drop shadow.
        loginMsgView.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = "🤔"
        loginMsgView.configureContent(title: "Oh-no!", body: "Please login first", iconText: iconText)
        
        loginMsgView.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        loginMsgView.button?.setTitle("Login", for: .normal)
        loginMsgView.button?.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        
        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        loginMsgView.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (loginMsgView.backgroundView as? CornerRoundingView)?.cornerRadius = GlobalCornerRadius.value
    }
    
    
    @objc private func showLoginVC(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        delegate?.showLoginVC()
    }
    
    //get trending events list
    func getTrendingEvents() {
        EventService.getTrendingEvents().done { response in
            self.trendingEvents = response.list.reversed()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    //refresh bookmarkBtn state
    @objc private func refreshTrendingSectionCell(_ notification: Notification) {
        let visibleCells = trendingCollectionView.visibleCells as! [TrendingCell]
        if let event = notification.userInfo {
            if let removeId = event["remove_id"] as? String {  //Callback from Bookmarked Section
                self.bookmarkedEventArray.remove(object: removeId) //remove id from local array
                print(self.bookmarkedEventArray)
                
                for cell in visibleCells {
                    if cell.eventID == removeId { //remove bookmark
                        self.removeBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let checkID = event["check_id"] as? String { //Callback from Event Details
                UserService.getBookmarkedEvents().done { response in
                    if !response.list.isEmpty {
                        if response.list.contains(where: { $0.targetEvent?.id == checkID }) { //check visible cell is bookmarked or not
                            for cell in visibleCells { //check bookmarked list contains id
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //add bookmark
                                    if !self.bookmarkedEventArray.contains(checkID) {
                                        self.bookmarkedEventArray.append(checkID)
                                        print("Callback from details array \(self.bookmarkedEventArray)")
                                    }
                                    self.addBookmarkAnimation(cell: cell)
                                }
                            }
                            
                        } else { //checkID is not in bookmarked list
                            if self.bookmarkedEventArray.contains(checkID) {
                                self.bookmarkedEventArray.remove(object: checkID)
                            }
                            
                            for cell in visibleCells {
                                if cell.eventID == checkID && (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.mintGreen()))! {
                                    self.removeBookmarkAnimation(cell: cell)
                                }
                            }
                        }
                        
                    } else { //bookmarked list is empty, remove id from array
                        if self.bookmarkedEventArray.contains(checkID) {
                            self.bookmarkedEventArray.remove(object: checkID)
                        }
                        
                        for cell in visibleCells {
                            self.removeBookmarkAnimation(cell: cell)
                        }
                    }
                    }.ensure { UIApplication.shared.isNetworkActivityIndicatorVisible = false }.catch { error in }
                
            }
        }
    }
    
    private func addBookmarkAnimation(cell: TrendingCell) {
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
    
    private func removeBookmarkAnimation(cell: TrendingCell) {
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
                UIView.animate(withDuration: 0.75) {
                    view.alpha = 1.0
                }
            }
            
            if let imgUrl = URL(string: (trendingEvents[indexPath.row].images.first?.secureUrl)!) {
                cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.4))])
            }
            
            if let id = trendingEvents[indexPath.row].id {
                cell.eventID = id
            }
            
            cell.eventTitle.text = trendingEvents[indexPath.row].title
            cell.performerTitle.text = trendingEvents[indexPath.row].organizerProfile?.name
            cell.dateLabel.text = trendingEvents[indexPath.row].dateTime
            cell.bookmarkBtn.backgroundColor = .clear
            
            //detemine bookmarkBtn bg color
            if UserService.User.isLoggedIn() {
                if let eventID = trendingEvents[indexPath.row].id {
                    if !bookmarkedEventArray.contains(eventID) {
                        /* Check if local array is holding this bookmarked cell
                         NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server */
                        
                        UserService.getBookmarkedEvents().done { response in
                            if !response.list.isEmpty {
                                for event in response.list {
                                    //check if bookmarked list contains id
                                    let isBookmarked = event.targetEvent?.id == self.trendingEvents[indexPath.row].id
                                    if isBookmarked {
                                        self.bookmarkedEventArray.append(eventID) //add this cell to local array to avoid reuse
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
        delegate?.trendingCellTapped(eventID: trendingEvents[indexPath.row].id ?? "")
    }
}

//Bookmark action
extension TrendingSection: TrendingCellDelegate {
    func bookmarkBtnTapped(cell: TrendingCell, tappedIndex: IndexPath) {
        cell.checkShouldDisplayIndicator()
        if UserService.User.isLoggedIn() {
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
                            if !self.bookmarkedEventArray.contains(eventID) {
                                self.bookmarkedEventArray.append(eventID)
                                print("Trending Section array: \(self.bookmarkedEventArray)\n")
                            }
                            
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["add_id": eventID]) //reload collection view in BookmarkedSection
                            
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
                            
                            if let index = self.bookmarkedEventArray.index(of: eventID) {
                                self.bookmarkedEventArray.remove(at: index)
                                print("Trending Section array: \(self.bookmarkedEventArray)\n")
                            }
                            
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["remove_id": eventID]) //reload collection view in BookmarkedSection
                            
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            HapticFeedback.createNotificationFeedback(style: .success)
                        }.catch { error in }
                }
                
            } else {
                print("Can't get trending section event id")
            }
            
        } else { // not logged in
            SwiftMessages.show(view: loginMsgView)
        }
        
    }
    
}
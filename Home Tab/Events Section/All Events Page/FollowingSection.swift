//
//  FollowingSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import SwiftMessages
import NVActivityIndicatorView
import Pastel

protocol FollowingSectionDelegate: class {
    func followingCellTapped(eventID: String)
}

class FollowingSection: UICollectionViewCell {
    static let reuseIdentifier = "followingSection"
    
    weak var delegate: FollowingSectionDelegate?

    var loadingIndicator: NVActivityIndicatorView!
    
    static let height: CGFloat = 244
    
    @IBOutlet weak var followingSectionTitle: UILabel!
    @IBOutlet weak var followingSectionCollectionView: UICollectionView!
    @IBOutlet var layoutConstraints: Array<NSLayoutConstraint>! //disable constraints to hide this section if user is not logged in
    
    var userFollowings: [OrganizerProfileObject] = [] {
        didSet {
            if userFollowings.isEmpty {
                setupEmptyFollowingView()
                
                followingSectionCollectionView.alpha = 0
                emptyFollowingShadowView.alpha = 1
            }
        }
    }
    
    var userFollowingsEvents: [Event] = [] {
        didSet {
            if userFollowingsEvents.isEmpty {
                setupEmptyFollowingEventsView()
                
                followingSectionCollectionView.alpha = 0
                emptyFollowingEventsShadowView.alpha = 1
            }
        }
    }
    
    var eventsLimit = 6 //event limit per request
    var gotMoreEvents = true //lazy loading
    
    var bookmarkedEventIDArray: [String] = [] //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    
    //empty followings view (i.e. didn't follow any buskers)
    var emptyFollowingBgView = UIView()
    var emptyFollowingGradientBg = PastelView()
    var emptyFollowingShadowView = UIView()
    
    //empty following events view (i.e. followed busker don't have any events)
    var emptyFollowingEventsBgView = UIView()
    var emptyFollowingEventsGradientBg = PastelView()
    var emptyFollowingEventsShadowView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.setObserver(self, selector: #selector(refreshFollowingSection), name: .refreshFollowingSection, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshFollowingSectionCell(_:)), name: .refreshFollowingSectionCell, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(removeAllObservers), name: .removeFollowingSectionObservers, object: nil)
        
        setupUI()
        
        if UserService.User.isLoggedIn() {
            getCurrentUserFollowings()
            getCurrentUserFollowingsEvents(limit: eventsLimit)
        }
    }
    
    //remove observers
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: UI related
extension FollowingSection {
    private func setupUI() {
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
        
        followingSectionCollectionView.backgroundColor = .m7DarkGray()
        followingSectionCollectionView.register(UINib.init(nibName: "FollowingCell", bundle: nil), forCellWithReuseIdentifier: FollowingCell.reuseIdentifier)
        
        setupLoadingIndicator()
    }
    
    private func addBookmarkAnimation(cell: FollowingCell) {
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
    
    private func removeBookmarkAnimation(cell: FollowingCell) {
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
    
    private func setupLoadingIndicator() {
        loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15)), type: .lineScale)
        loadingIndicator.alpha = 0
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) in
            make.left.equalTo(followingSectionTitle.snp.right).offset(10)
            make.centerY.equalTo(followingSectionTitle)
            make.size.equalTo(15)
        }
    }
    
    private func setupEmptyFollowingView() {
        //empty view's drop shadow
        emptyFollowingShadowView.alpha = 0
        emptyFollowingShadowView.frame = CGRect(x: 20, y: 59, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingShadowView.clipsToBounds = false
        emptyFollowingShadowView.layer.shadowOpacity = 0.5
        emptyFollowingShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyFollowingShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyFollowingShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyFollowingShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyFollowingBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyFollowingBgView.clipsToBounds = true
        emptyFollowingBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyFollowingGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingGradientBg.animationDuration = 3
        emptyFollowingGradientBg.setColors([UIColor(hexString: "#3a7bd5"), UIColor(hexString: "#00d2ff")])
        emptyFollowingShadowView.layer.shadowColor = UIColor(hexString: "#00d2ff").cgColor
        
        emptyFollowingGradientBg.startAnimation()
        
        emptyFollowingBgView.insertSubview(emptyFollowingGradientBg, at: 0)
        emptyFollowingShadowView.addSubview(emptyFollowingBgView)
        
        let emptyFollowingImgView = UIImageView()
        emptyFollowingImgView.image = UIImage(named: "icon_follow")
        emptyFollowingBgView.addSubview(emptyFollowingImgView)
        emptyFollowingImgView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(25)
        }
        
        let emptyFollowingDesc = UILabel()
        emptyFollowingDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        emptyFollowingDesc.text = "Go follow your favourite artists now!"
        emptyFollowingDesc.textColor = .white
        emptyFollowingDesc.numberOfLines = 2
        emptyFollowingBgView.addSubview(emptyFollowingDesc)
        emptyFollowingDesc.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalTo(25)
            make.width.equalTo(230)
        }
        
        let emptyFollowingTitle = UILabel()
        emptyFollowingTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        emptyFollowingTitle.text = "It's empty..."
        emptyFollowingTitle.textColor = .white
        emptyFollowingBgView.addSubview(emptyFollowingTitle)
        emptyFollowingTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(emptyFollowingDesc.snp.top).offset(-5)
            make.left.equalTo(25)
            make.width.equalTo(200)
        }
        
        //        let learnMoreBtn = UIButton()
        //        learnMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        //        learnMoreBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        //        learnMoreBtn.setTitle("Learn More", for: .normal)
        //        learnMoreBtn.setTitleColor(.darkPurple(), for: .normal)
        //        learnMoreBtn.backgroundColor = .white
        //        emptyBookmarkBgView.addSubview(learnMoreBtn)
        //        learnMoreBtn.snp.makeConstraints { (make) in
        //            make.bottomMargin.equalTo(emptyBookmarkBgView.snp.bottom).offset(-25)
        //            make.rightMargin.equalTo(emptyBookmarkBgView.snp.right).offset(-25)
        //            make.width.equalTo(120)
        //            make.height.equalTo(28)
        //        }
        //
        //        learnMoreBtn.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        addSubview(emptyFollowingShadowView)
        
    }
    
    private func setupEmptyFollowingEventsView() {
        //empty view's drop shadow
        emptyFollowingEventsShadowView.alpha = 0
        emptyFollowingEventsShadowView.frame = CGRect(x: 20, y: 59, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingEventsShadowView.clipsToBounds = false
        emptyFollowingEventsShadowView.layer.shadowOpacity = 0.5
        emptyFollowingEventsShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyFollowingEventsShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyFollowingEventsShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyFollowingEventsShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyFollowingEventsBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingEventsBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyFollowingEventsBgView.clipsToBounds = true
        emptyFollowingEventsBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyFollowingEventsGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 12)
        emptyFollowingEventsGradientBg.animationDuration = 2.5
        emptyFollowingEventsGradientBg.setColors([UIColor(hexString: "#753a88"), UIColor(hexString: "#cc2b5e")])
        emptyFollowingEventsShadowView.layer.shadowColor = UIColor(hexString: "#cc2b5e").cgColor
        
        emptyFollowingEventsGradientBg.startAnimation()
        
        emptyFollowingEventsBgView.insertSubview(emptyFollowingEventsGradientBg, at: 0)
        emptyFollowingEventsShadowView.addSubview(emptyFollowingEventsBgView)
        
        let emptyFollowingEventsImgView = UIImageView()
        emptyFollowingEventsImgView.image = UIImage(named: "icon_music_production")
        emptyFollowingEventsBgView.addSubview(emptyFollowingEventsImgView)
        emptyFollowingEventsImgView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(25)
        }
        
        let emptyFollowingEventsDesc = UILabel()
        emptyFollowingEventsDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        emptyFollowingEventsDesc.text = "Maybe they're planning something big?"
        emptyFollowingEventsDesc.textColor = .white
        emptyFollowingEventsDesc.numberOfLines = 2
        emptyFollowingEventsBgView.addSubview(emptyFollowingEventsDesc)
        emptyFollowingEventsDesc.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalTo(25)
            make.width.equalTo(230)
        }
        
        let emptyFollowingEventsTitle = UILabel()
        emptyFollowingEventsTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        emptyFollowingEventsTitle.text = "BUSKER_NAME currently don't have any events!"
        emptyFollowingEventsTitle.textColor = .white
        emptyFollowingEventsTitle.numberOfLines = 2
        emptyFollowingEventsBgView.addSubview(emptyFollowingEventsTitle)
        emptyFollowingEventsTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(emptyFollowingEventsDesc.snp.top).offset(-6)
            make.left.equalTo(25)
            make.width.equalTo(UIScreen.main.bounds.width - 90)
        }
        
        //        let learnMoreBtn = UIButton()
        //        learnMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        //        learnMoreBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        //        learnMoreBtn.setTitle("Learn More", for: .normal)
        //        learnMoreBtn.setTitleColor(.darkPurple(), for: .normal)
        //        learnMoreBtn.backgroundColor = .white
        //        emptyBookmarkBgView.addSubview(learnMoreBtn)
        //        learnMoreBtn.snp.makeConstraints { (make) in
        //            make.bottomMargin.equalTo(emptyBookmarkBgView.snp.bottom).offset(-25)
        //            make.rightMargin.equalTo(emptyBookmarkBgView.snp.right).offset(-25)
        //            make.width.equalTo(120)
        //            make.height.equalTo(28)
        //        }
        //
        //        learnMoreBtn.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        addSubview(emptyFollowingEventsShadowView)
        
    }
}

//MARK: UICollectionView delegate
extension FollowingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = UserService.User.isLoggedIn() && !userFollowingsEvents.isEmpty ? userFollowingsEvents.count : 3
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = followingSectionCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingCell.reuseIdentifier, for: indexPath) as! FollowingCell
        if !userFollowingsEvents.isEmpty {
            let event = userFollowingsEvents[indexPath.row]
            
            cell.delegate = self
            cell.myIndexPath = indexPath
            cell.eventTitle.text = event.title
            cell.dateLabel.text = event.dateTime
            cell.performerLabel.text = event.organizerProfile?.name
            cell.bookmarkBtn.backgroundColor = .clear
            if let url = URL(string: event.images[0].secureUrl!) {
                cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
            }
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            for view in cell.viewsToShowLater {
                UIView.animate(withDuration: 0.3) {
                    view.alpha = 1
                }
            }
            
            if let id = userFollowingsEvents[indexPath.row].id {
                cell.eventID = id
            }
            
            //detemine bookmarkBtn bg color
            checkBookmarkBtnState(cell: cell, indexPath: indexPath)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == userFollowingsEvents.count - 1) {
            print("Fetching following events...")
            if gotMoreEvents {
                UIView.animate(withDuration: 0.2) {
                    self.loadingIndicator.alpha = 1
                }
                getCurrentUserFollowingsEvents(skip: userFollowingsEvents.count, limit: eventsLimit)
            } else {
                print("No more events to fetch!")
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: FollowingCell.width, height: FollowingCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.followingCellTapped(eventID: userFollowingsEvents[indexPath.row].id ?? "")
    }
    
}

//MARK: API Calls | Bookmark action | Bookmark btn state | Following cell delegate
extension FollowingSection: FollowingCellDelegate {
    func getCurrentUserFollowings(skip: Int? = nil, limit: Int? = nil, targetProfile: OrganizerProfile? = nil, targetType: Int? = nil) {
        UserService.getUserFollowings(skip: skip, limit: limit, targetProfile: targetProfile, targetType: targetType).done { response in
            self.userFollowings.append(contentsOf: response.list)
        }.ensure {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in }
    }
    
    func getCurrentUserFollowingsEvents(skip: Int? = nil, limit: Int? = nil) {
        followingSectionCollectionView.isUserInteractionEnabled = false
        EventService.getFollowingEvents(skip: skip, limit: limit).done { response in
            self.userFollowingsEvents.append(contentsOf: response.list)
            self.gotMoreEvents = response.list.count < self.eventsLimit || response.list.count == 0 ? false : true
            self.followingSectionCollectionView.reloadData()
            }.ensure {
                if self.loadingIndicator.alpha != 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.loadingIndicator.alpha = 0
                    }
                }
                self.followingSectionCollectionView.isUserInteractionEnabled = true
                NotificationCenter.default.post(name: .eventListEndRefreshing, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    //pull to refresh
    @objc func refreshFollowingSection() {
        //first clear data model
        bookmarkedEventIDArray.removeAll()
        userFollowings.removeAll()
        userFollowingsEvents.removeAll()
        
        if followingSectionCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                self.followingSectionCollectionView.alpha = 1
                self.emptyFollowingShadowView.alpha = 0
                self.emptyFollowingEventsShadowView.alpha = 0
            }
        }
        followingSectionCollectionView.setContentOffset(CGPoint.zero, animated: false)
        followingSectionCollectionView.reloadData()
        
        getCurrentUserFollowings()
        getCurrentUserFollowingsEvents()
    }
    
    func checkBookmarkBtnState(cell: FollowingCell, indexPath: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventID = userFollowingsEvents[indexPath.row].id {
                if !bookmarkedEventIDArray.contains(eventID) {
                    /* Check if local array is holding this bookmarked cell
                     NOTE: This check is to prevent cell reuse issues, all bookmarked events will be saved in server */
                    
                    UserService.getBookmarkedEvents().done { response in
                        if !response.list.isEmpty {
                            for event in response.list {
                                //check if bookmarked list contains id
                                let isBookmarked = event.targetEvent?.id == self.userFollowingsEvents[indexPath.row].id
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
    
    @objc private func refreshFollowingSectionCell(_ notification: Notification) {
        let visibleCells = followingSectionCollectionView.visibleCells as! [FollowingCell]
        if let event = notification.userInfo {
            if let addID = event["add_id"] as? String {
                self.bookmarkedEventIDArray.remove(object: addID) //add id from local array
                
                for cell in visibleCells {
                    if cell.eventID == addID { //add bookmark
                        self.addBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let removeID = event["remove_id"] as? String {  //Callback from Bookmarked Section , check after removing bookmark
                self.bookmarkedEventIDArray.remove(object: removeID) //remove id from local array
                
                for cell in visibleCells {
                    if cell.eventID == removeID { //remove bookmark
                        self.removeBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let checkID = event["check_id"] as? String { //Callback from Event Details, check after dismissing event details VC
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
    
    func bookmarkBtnTapped(cell: FollowingCell, tappedIndex: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventID = self.userFollowingsEvents[tappedIndex.row].id {
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
                            
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["add_id": eventID]) //refresh bookmarkBtn state in TrendingSection
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
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in TrendingSection
                            NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["remove_id": eventID]) //reload collection view in BookmarkedSection
                            
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

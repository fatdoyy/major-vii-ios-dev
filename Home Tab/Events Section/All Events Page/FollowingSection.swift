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
    
    static let height: CGFloat = 264
    
    @IBOutlet weak var followingSectionTitle: UILabel!
    @IBOutlet weak var followingSectionDesc: UILabel!
    @IBOutlet weak var followingsCollectionView: UICollectionView!
    @IBOutlet weak var followingSectionCollectionView: UICollectionView!
    @IBOutlet var layoutConstraints: Array<NSLayoutConstraint>! //disable constraints to hide this section if user is not logged in
    
    var userFollowings = [OrganizerProfileObject]()
    var followingsLimit = 7 //followings limit per request
    var gotMoreFollowings = true //lazy loading
    
    var userFollowingsEvents = [Event]()
    var eventsLimit = 6 //event limit per request
    var gotMoreEvents = true //lazy loading
    var selectedIndexPath: IndexPath? //control selected busker state
    
    var boolArr = [Int]()
    var bookmarkedEventIDArray = [String]() //IMPORTANT: Adding an array to local to control bookmarkBtn's state because of cell reuse issues
    
    //empty followings view (i.e. didn't follow any buskers)
    var emptyFollowingBgView = UIView()
    var emptyFollowingGradientBg = PastelView()
    var emptyFollowingShadowView = UIView()
    
    //empty following events view (i.e. followed busker don't have any events)
    var emptyFollowingEventsBgView = UIView()
    var emptyFollowingEventsGradientBg = PastelView()
    var emptyFollowingEventsShadowView = UIView()
    var emptyFollowingEventsTitle = UILabel() //control empty message text
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.setObserver(self, selector: #selector(refreshFollowingSection), name: .refreshFollowingSection, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshFollowingSectionCell(_:)), name: .refreshFollowingSectionCell, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(removeAllObservers), name: .removeFollowingSectionObservers, object: nil)
        
        setupUI()
        
        if UserService.current.isLoggedIn() {
            getCurrentUserFollowings(limit: followingsLimit)
        }
    }
    
    //remove observers
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

//MARK: - UI related
extension FollowingSection {
    private func setupUI() {
        followingSectionTitle.textColor = .whiteText()
        followingSectionTitle.text = "Your Followings"
        
        followingSectionDesc.textColor = .purpleText()
        followingSectionDesc.text = "Loading..."
        
        setupFollowingsCollectionView()
        setupFollowingSectionCollectionView()
        
        setupLoadingIndicator()
    }
    
    private func setupFollowingsCollectionView() {
        if let layout = followingsCollectionView.collectionViewLayout as? HashtagsFlowLayout { //using the same layout as hashtags
            layout.scrollDirection = .horizontal
        }
        
        followingsCollectionView.alpha = 0
        followingsCollectionView.dataSource = self
        followingsCollectionView.delegate = self
        
        followingsCollectionView.showsVerticalScrollIndicator = false
        followingsCollectionView.showsHorizontalScrollIndicator = false
        
        followingsCollectionView.backgroundColor = .m7DarkGray()
        followingsCollectionView.register(UINib.init(nibName: "FollowingsCell", bundle: nil), forCellWithReuseIdentifier: FollowingsCell.reuseIdentifier)
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(followingsCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(followingsCollectionView.snp.top)
            make.left.equalTo(followingsCollectionView.snp.left)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(followingsCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(followingsCollectionView.snp.top)
            make.right.equalTo(followingsCollectionView.snp.right)
        }
    }
    
    private func setupFollowingSectionCollectionView() {
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
        followingSectionCollectionView.register(UINib.init(nibName: "FollowingSectionCell", bundle: nil), forCellWithReuseIdentifier: FollowingSectionCell.reuseIdentifier)
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(followingSectionCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(followingSectionCollectionView.snp.top)
            make.left.equalTo(followingSectionCollectionView.snp.left)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(followingSectionCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(followingSectionCollectionView.snp.top)
            make.right.equalTo(followingSectionCollectionView.snp.right)
        }
    }
    
    private func addBookmarkAnimation(cell: FollowingSectionCell) {
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
    
    private func removeBookmarkAnimation(cell: FollowingSectionCell) {
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
    
    private func setupEmptyFollowingsView() {
        //empty view's drop shadow
        emptyFollowingShadowView.alpha = 0
        emptyFollowingShadowView.frame = CGRect(x: 20, y: 91, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
        emptyFollowingShadowView.clipsToBounds = false
        emptyFollowingShadowView.layer.shadowOpacity = 0.5
        emptyFollowingShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyFollowingShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyFollowingShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyFollowingShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyFollowingBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
        emptyFollowingBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyFollowingBgView.clipsToBounds = true
        emptyFollowingBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyFollowingGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
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
        emptyFollowingEventsShadowView.frame = CGRect(x: 20, y: 91, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
        emptyFollowingEventsShadowView.clipsToBounds = false
        emptyFollowingEventsShadowView.layer.shadowOpacity = 0.5
        emptyFollowingEventsShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyFollowingEventsShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyFollowingEventsShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyFollowingEventsShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyFollowingEventsBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
        emptyFollowingEventsBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyFollowingEventsBgView.clipsToBounds = true
        emptyFollowingEventsBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyFollowingEventsGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: followingSectionCollectionView.frame.height - 11)
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
        emptyFollowingEventsDesc.text = "Working hard building something..."
        emptyFollowingEventsDesc.textColor = .white
        emptyFollowingEventsDesc.numberOfLines = 2
        emptyFollowingEventsBgView.addSubview(emptyFollowingEventsDesc)
        emptyFollowingEventsDesc.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalTo(25)
            make.width.equalTo(230)
        }
        
        emptyFollowingEventsTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
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

//MARK: - UICollectionView delegate
extension FollowingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case followingsCollectionView:
            let count = UserService.current.isLoggedIn() && !userFollowings.isEmpty ? userFollowings.count : 0
            return count
            
        case followingSectionCollectionView:
            let count = UserService.current.isLoggedIn() && !userFollowingsEvents.isEmpty ? userFollowingsEvents.count : 3
            return count
            
        default: return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case followingsCollectionView:
            let cell = followingsCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingsCell.reuseIdentifier, for: indexPath) as! FollowingsCell
            cell.name.text = UserService.current.isLoggedIn() && !userFollowings.isEmpty ? userFollowings[indexPath.row].targetProfile?.name : "EMPTY"
            cell.name.textColor = (self.selectedIndexPath != nil && indexPath == self.selectedIndexPath) ? .m7DarkGray() : .purpleText()
            cell.backgroundColor = (self.selectedIndexPath != nil && indexPath == self.selectedIndexPath) ? .purpleText() : UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
            return cell
            
        case followingSectionCollectionView:
            let cell = followingSectionCollectionView.dequeueReusableCell(withReuseIdentifier: FollowingSectionCell.reuseIdentifier, for: indexPath) as! FollowingSectionCell
            if !userFollowingsEvents.isEmpty {
                let event = userFollowingsEvents[indexPath.row]
                
                for view in cell.skeletonViews { //hide all skeleton views
                    view.hideSkeleton()
                }
                
                if let id = userFollowingsEvents[indexPath.row].id {
                    cell.eventID = id
                }
                
                cell.delegate = self
                cell.myIndexPath = indexPath
                cell.eventTitle.text = event.title
                
                if let eventDate = event.dateTime?.toDate(), let currentDate = Date().toISO().toDate() {
                    let difference = DateTimeHelper.getEventInterval(from: currentDate, to: eventDate)
                    cell.dateLabel.text = difference
                }

                cell.performerLabel.text = event.organizerProfile?.name
                cell.bookmarkBtn.backgroundColor = .clear
                if let url = URL(string: event.images[0].secureUrl!) {
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                
                for view in cell.viewsToShowLater {
                    UIView.animate(withDuration: 0.3) {
                        view.alpha = 1
                    }
                }
                
                UIView.animate(withDuration: 0.4) {
                    cell.premiumBadge.alpha = self.boolArr[indexPath.row] == 1 ? 1 : 0
                }
                cell.verifiedIcon.alpha = self.userFollowingsEvents[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
                
                //detemine bookmarkBtn bg color
                checkBookmarkBtnState(cell: cell, indexPath: indexPath)
            }
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView {
        case followingsCollectionView:
            if (indexPath.row == userFollowings.count - 2) {
                print("Fetching followings...")
                if gotMoreFollowings {
                    UIView.animate(withDuration: 0.2) {
                        self.loadingIndicator.alpha = 1
                    }
                    getCurrentUserFollowings(skip: userFollowings.count, limit: followingsLimit)
                } else {
                    print("No more followingss to fetch!")
                }
                
            }
            
        case followingSectionCollectionView:
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
            
        default: print("error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case followingsCollectionView:
            let name = UserService.current.isLoggedIn() && !userFollowings.isEmpty ? userFollowings[indexPath.row].targetProfile?.name : "EMPTY"
            let size = (name! as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: FollowingsCell.height)
            
        case followingSectionCollectionView:
            return CGSize(width: FollowingSectionCell.width, height: FollowingSectionCell.height)
            
        default:
            return CGSize(width: FollowingSectionCell.width, height: FollowingSectionCell.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case followingsCollectionView:
            HapticFeedback.createImpact(style: .medium)
            let cell = followingsCollectionView.cellForItem(at: indexPath) as! FollowingsCell
            
            if let ID = userFollowings[indexPath.row].targetProfile?.id, let name = userFollowings[indexPath.row].targetProfile?.name {
                if selectedIndexPath != indexPath || selectedIndexPath == nil { //if not yet selected
                    UIView.animate(withDuration: 0.2) {
                        cell.backgroundColor = .purpleText()
                        cell.name.textColor = .m7DarkGray()
                    }
                    
                    selectedIndexPath = indexPath
                    bookmarkedEventIDArray.removeAll()
                    getSelectedBuskerEvents(buskerID: ID, name: name, limit: eventsLimit)
                } else if selectedIndexPath == indexPath && selectedIndexPath != nil { //if selected same busker again, do diselect action (i.e show all events)
                    UIView.animate(withDuration: 0.2) {
                        cell.backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
                        cell.name.textColor = .purpleText()
                    }
                    
                    if emptyFollowingEventsShadowView.alpha != 0 { //ensure empty events view is hidden
                        UIView.animate(withDuration: 0.2) {
                            self.emptyFollowingEventsShadowView.alpha = 0
                            self.followingSectionCollectionView.alpha = 1
                        }
                    }
                    selectedIndexPath = nil
                    bookmarkedEventIDArray.removeAll()
                    userFollowingsEvents.removeAll()
                    followingSectionCollectionView.reloadData()
                    getCurrentUserFollowingsEvents(limit: eventsLimit)
                }

            }
            
        case followingSectionCollectionView:
            delegate?.followingCellTapped(eventID: userFollowingsEvents[indexPath.row].id ?? "")
            
        default: print("error")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch collectionView {
        case followingsCollectionView:
            if let selectedCell = followingsCollectionView.cellForItem(at: indexPath) {
                let cell = selectedCell as! FollowingsCell
                UIView.animate(withDuration: 0.2) {
                    cell.backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
                    cell.name.textColor = .purpleText()
                }
            } else {
                
            }
            selectedIndexPath = nil

        default: print("no action needed")
        }
    }
}

//MARK: - API Calls | Bookmark action | Bookmark btn state | Following cell delegate
extension FollowingSection: FollowingSectionCellDelegate {
    func getCurrentUserFollowings(skip: Int? = nil, limit: Int? = nil, targetProfile: OrganizerProfile? = nil, targetType: Int? = nil) {
        followingsCollectionView.isUserInteractionEnabled = false
        UserService.getUserFollowings(skip: skip, limit: limit, targetProfile: targetProfile, targetType: targetType).done { response in
            if !response.list.isEmpty {
                self.userFollowings.append(contentsOf: response.list)
                self.gotMoreFollowings = response.list.count < self.followingsLimit || response.list.count == 0 ? false : true
                
                self.getCurrentUserFollowingsEvents(limit: self.eventsLimit)
                
                UIView.animate(withDuration: 0.2) {
                    self.followingSectionDesc.alpha = 0
                    self.followingsCollectionView.alpha = 1
                    self.emptyFollowingShadowView.alpha = 0
                }
            } else { //empty
                self.followingSectionDesc.text = "0 followers"
                self.setupEmptyFollowingsView()
                self.emptyFollowingShadowView.alpha = 1
                self.followingsCollectionView.alpha = 0
                self.followingSectionCollectionView.alpha = 0
            }
        }.ensure {
            if self.loadingIndicator.alpha != 0 {
                UIView.animate(withDuration: 0.2) {
                    self.loadingIndicator.alpha = 0
                }
            }
            self.followingsCollectionView.reloadData()
            self.followingsCollectionView.isUserInteractionEnabled = true
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in }
    }
    
    func getCurrentUserFollowingsEvents(skip: Int? = nil, limit: Int? = nil) {
        followingSectionCollectionView.isUserInteractionEnabled = false
        EventService.getFollowingEvents(skip: skip, limit: limit).done { response in
            self.userFollowingsEvents.append(contentsOf: response.list)
            self.gotMoreEvents = response.list.count < self.eventsLimit || response.list.count == 0 ? false : true
            for _ in 0 ..< self.userFollowingsEvents.count {
                self.boolArr.append(Int.random(in: 0 ... 1))
            }
            if self.userFollowingsEvents.isEmpty { //setup empty view
                self.setupEmptyFollowingEventsView()
                if self.userFollowings.count == 1 && self.userFollowingsEvents.isEmpty {
                    self.emptyFollowingEventsTitle.text = "\(self.userFollowings.first?.targetProfile?.name ?? "") currently don't have any events!"
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.followingSectionCollectionView.alpha = 0
                    self.emptyFollowingEventsShadowView.alpha = 1
                })
            }
        }.ensure {
            if self.loadingIndicator.alpha != 0 {
                UIView.animate(withDuration: 0.2) {
                    self.loadingIndicator.alpha = 0
                }
            }
            self.followingSectionCollectionView.reloadData()
            self.followingSectionCollectionView.isUserInteractionEnabled = true
            NotificationCenter.default.post(name: .eventListEndRefreshing, object: nil)
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.catch { error in }
    }
    
    func getSelectedBuskerEvents(buskerID: String, name: String, skip: Int? = nil, limit: Int? = nil) {
        followingsCollectionView.isUserInteractionEnabled = false
        followingSectionCollectionView.isUserInteractionEnabled = false
        
        bookmarkedEventIDArray.removeAll()
        userFollowingsEvents.removeAll()
        
        emptyFollowingEventsShadowView.alpha = 0
        if followingSectionCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                self.followingSectionCollectionView.alpha = 1
            }
        }
        followingSectionCollectionView.setContentOffset(CGPoint.zero, animated: false)
        followingSectionCollectionView.reloadData()
        
        BuskerService.getBuskerEvents(buskerID: buskerID).done { response -> () in
            self.userFollowingsEvents.append(contentsOf: response.list)
            self.gotMoreEvents = self.userFollowingsEvents.count < self.eventsLimit || self.userFollowingsEvents.count == 0 ? false : true
            self.followingSectionCollectionView.reloadData()
            
            if self.userFollowingsEvents.isEmpty { //setup empty view
                self.setupEmptyFollowingEventsView()
                self.emptyFollowingEventsTitle.text = "\(name) currently don't have any events!"
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.followingSectionCollectionView.alpha = 0
                    self.emptyFollowingEventsShadowView.alpha = 1
                })
            }
            }.ensure {
                if self.loadingIndicator.alpha != 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.loadingIndicator.alpha = 0
                    }
                }
                
                self.followingsCollectionView.isUserInteractionEnabled = true
                self.followingSectionCollectionView.isUserInteractionEnabled = true
                NotificationCenter.default.post(name: .eventListEndRefreshing, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    //pull to refresh
    @objc func refreshFollowingSection() {
        gotMoreFollowings = true
        gotMoreEvents = true
        
        //first clear data model
        bookmarkedEventIDArray.removeAll()
        userFollowings.removeAll()
        userFollowingsEvents.removeAll()
        
        UIView.animate(withDuration: 0.2) {
            self.followingSectionDesc.alpha = 1
            self.followingsCollectionView.alpha = 0
        }
        
        followingSectionDesc.text = "Loading"
        emptyFollowingShadowView.alpha = 0
        emptyFollowingEventsShadowView.alpha = 0
        if followingSectionCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                self.followingSectionCollectionView.alpha = 1
            }
        }
        followingSectionCollectionView.setContentOffset(CGPoint.zero, animated: false)
        followingSectionCollectionView.reloadData()
        
        getCurrentUserFollowings(limit: followingsLimit)
    }
    
    func checkBookmarkBtnState(cell: FollowingSectionCell, indexPath: IndexPath) {
        if UserService.current.isLoggedIn() {
            if let eventID = userFollowingsEvents[indexPath.row].id {
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
                        }.ensure { UIApplication.shared.isNetworkActivityIndicatorVisible = false }.catch { error in }
                    
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
        let visibleCells = followingSectionCollectionView.visibleCells as! [FollowingSectionCell]
        if let event = notification.userInfo {
            if let addID = event["add_id"] as? String {
                bookmarkedEventIDArray.remove(object: addID) //add id from local array
                
                for cell in visibleCells {
                    if cell.eventID == addID { //add bookmark
                        addBookmarkAnimation(cell: cell)
                    }
                }
                
            } else if let removeID = event["remove_id"] as? String {  //Callback from Bookmarked Section , check after removing bookmark
                bookmarkedEventIDArray.remove(object: removeID) //remove id from local array
                
                for cell in visibleCells {
                    if cell.eventID == removeID { //remove bookmark
                        removeBookmarkAnimation(cell: cell)
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
    
    func bookmarkBtnTapped(cell: FollowingSectionCell, tappedIndex: IndexPath) {
        if UserService.current.isLoggedIn() {
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
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["remove_id": eventID]) //refresh bookmarkBtn state in TrendingSection
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

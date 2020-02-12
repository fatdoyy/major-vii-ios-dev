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
import Pastel

protocol BookmarkSectionDelegate: class {
    func bookmarkedCellTapped(eventID: String)
    func showLoginVC()
}

class BookmarkedSection: UICollectionViewCell {
    static let reuseIdentifier = "bookmarkSection"
    
    weak var delegate: BookmarkSectionDelegate?

    static let height: CGFloat = 250
    
    @IBOutlet weak var bookmarkSectionTitle: UILabel!
    @IBOutlet weak var bookmarksCountLabel: UILabel!
    @IBOutlet weak var bookmarksCollectionView: UICollectionView!
    
    var emptyLoginBgView = UIView()
    var emptyLoginGradientBg = PastelView()
    var emptyLoginShadowView = UIView()
    
    var emptyBookmarkBgView = UIView()
    var emptyBookmarkGradientBg = PastelView()
    var emptyBookmarkShadowView = UIView()
    
    var bookmarkedEventIDArray = [String]() //to refresh TrendingSectionCell bookmakrBtn state
    var boolArr = [Int]()
    
    var reloadIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)), type: .lineScale)
    
    var bookmarkedEvents = [BookmarkedEvent]() {
        didSet {
            if emptyLoginShadowView.alpha == 1 { //ensure empty login view is hidden
                UIView.animate(withDuration: 0.2) {
                    self.emptyLoginShadowView.alpha = 0
                }
            }
            
            bookmarksCountLabel.text = bookmarkedEvents.count == 1 ? "1 Event" : "\(bookmarkedEvents.count) Events"
            
            if bookmarksCollectionView.alpha == 0 && bookmarkedEvents.count != 0 {
                UIView.animate(withDuration: 0.2) {
                    self.bookmarksCollectionView.alpha = 1
                    self.emptyBookmarkShadowView.alpha = 0
                }
            } else if bookmarksCollectionView.alpha == 0 && (oldValue.count == 0 || bookmarkedEvents.count == 0) { //show empty view
                emptyLoginGradientBg.startAnimation()
                UIView.animate(withDuration: 0.2) {
                    self.emptyBookmarkShadowView.alpha = 1
                }
            } else if bookmarksCollectionView.alpha != 0 && bookmarkedEvents.count == 0 {
                self.emptyBookmarkGradientBg.startAnimation()
                UIView.animate(withDuration: 0.2) {
                    self.bookmarksCollectionView.alpha = 0
                    self.emptyBookmarkShadowView.alpha = 1
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.setObserver(self, selector: #selector(refreshBookmarkedSection(_:)), name: .refreshBookmarkedSection, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(removeAllObservers), name: .removeBookmarkedSectionObservers, object: nil)
        
        setupUI()
    }
    
    @objc private func refreshBookmarkedSection(_ notification: Notification) {
        UIView.animate(withDuration: 0.2) {
            if self.emptyBookmarkShadowView.alpha != 0 {
                self.emptyBookmarkShadowView.alpha = 0
            }
            self.bookmarksCollectionView.alpha = 0
            self.bookmarksCountLabel.text = "Loading..."
            self.reloadIndicator.alpha = 1
        }
        
        if let data = notification.userInfo {
            if let eventID = data["add_id"] as? String {
                print("Recieved event id: \(eventID), double checking BookmarkedSection's bookmarkedEventIdArray...")
                if !self.bookmarkedEventIDArray.contains(eventID) {
                    self.bookmarkedEventIDArray.append(eventID)
                    print("\(eventID) is added to bookmarkedEventIdArray - bookmarkedEventIdArray: \(self.bookmarkedEventIDArray)\n")
                }
            } else if let eventID = data["remove_id"] as? String {
                if self.bookmarkedEventIDArray.contains(eventID) {
                    self.bookmarkedEventIDArray.remove(object: eventID)
                    print("Recieved remove id: \(eventID) - bookmarkedEventIdArray: \(self.bookmarkedEventIDArray)\n")
                }
            }
        }
        
        getBookmarkedEvents()
    }
    
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

//MARK: - UI related
extension BookmarkedSection {
    private func setupUI() {
        bookmarkSectionTitle.textColor = .whiteText()
        bookmarkSectionTitle.text = "Your Bookmarks"
        
        bookmarksCountLabel.textColor = .purpleText()
        bookmarksCountLabel.text = "Loading..."
        
        if let layout = bookmarksCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        bookmarksCollectionView.isUserInteractionEnabled = false
        bookmarksCollectionView.dataSource = self
        bookmarksCollectionView.delegate = self
        
        bookmarksCollectionView.showsVerticalScrollIndicator = false
        bookmarksCollectionView.showsHorizontalScrollIndicator = false
        
        bookmarksCollectionView.backgroundColor = .m7DarkGray()
        bookmarksCollectionView.register(UINib.init(nibName: "BookmarkedSectionCell", bundle: nil), forCellWithReuseIdentifier: BookmarkedSectionCell.reuseIdentifier)
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(bookmarksCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(bookmarksCollectionView.snp.top)
            make.left.equalTo(bookmarksCollectionView.snp.left)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(bookmarksCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(bookmarksCollectionView.snp.top)
            make.right.equalTo(bookmarksCollectionView.snp.right)
        }
        
        reloadIndicator.startAnimating()
        reloadIndicator.alpha = 0
        addSubview(reloadIndicator)
        reloadIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(bookmarksCollectionView.snp.centerX)
            make.centerY.equalTo(bookmarksCollectionView.snp.centerY)
        }
        
        if UserService.current.isLoggedIn() {
            getBookmarkedEvents()
        } else {
            bookmarksCollectionView.alpha = 0
            setupEmptyLoginView()
            emptyLoginShadowView.alpha = 1
        }
    }
    
    private func setupEmptyLoginView() {
        //empty view's drop shadow
        emptyLoginShadowView.alpha = 0
        emptyLoginShadowView.frame = CGRect(x: 20, y: 78, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyLoginShadowView.clipsToBounds = false
        emptyLoginShadowView.layer.shadowOpacity = 0.5
        emptyLoginShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyLoginShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyLoginShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyLoginShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyLoginBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyLoginBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyLoginBgView.clipsToBounds = true
        emptyLoginBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyLoginGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyLoginGradientBg.animationDuration = 2.5
        emptyLoginGradientBg.setColors([UIColor(hexString: "#FDC830"), UIColor(hexString: "#F37335")])
        emptyLoginShadowView.layer.shadowColor = UIColor(hexString: "#FDC830").cgColor
        
        emptyLoginGradientBg.startAnimation()
        
        emptyLoginBgView.insertSubview(emptyLoginGradientBg, at: 0)
        emptyLoginShadowView.addSubview(emptyLoginBgView)
        
        let loginImgView = UIImageView()
        loginImgView.image = UIImage(named: "icon_login")
        emptyLoginBgView.addSubview(loginImgView)
        loginImgView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.size.equalTo(40)
        }
        
        let loginTitle = UILabel()
        loginTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        loginTitle.text = "Log-in now!"
        loginTitle.textColor = .white
        emptyLoginBgView.addSubview(loginTitle)
        loginTitle.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.left.equalTo(loginImgView.snp.right).offset(12)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }
        
        let loginBtn = UIButton()
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        loginBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        loginBtn.setTitle("Sure!", for: .normal)
        loginBtn.setTitleColor(UIColor(hexString: "#F37335"), for: .normal)
        loginBtn.backgroundColor = .white
        emptyLoginBgView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
        loginBtn.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        
        let loginDesc = UILabel()
        loginDesc.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        loginDesc.text = "Enjoy full experience with your Major VII account."
        loginDesc.textColor = .white
        loginDesc.numberOfLines = 2
        emptyLoginBgView.addSubview(loginDesc)
        loginDesc.snp.makeConstraints { (make) in
            make.top.equalTo(loginBtn.snp.top)
            make.left.equalTo(25)
            make.width.equalTo(200)
        }
        
        addSubview(emptyLoginShadowView)
    }
    
    @objc private func showLoginVC(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        delegate?.showLoginVC()
    }
    
    private func setupEmptyBookmarkView() {
        //empty view's drop shadow
        emptyBookmarkShadowView.alpha = 0
        emptyBookmarkShadowView.frame = CGRect(x: 20, y: 78, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyBookmarkShadowView.clipsToBounds = false
        emptyBookmarkShadowView.layer.shadowOpacity = 0.5
        emptyBookmarkShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyBookmarkShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyBookmarkShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyBookmarkShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        emptyBookmarkBgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyBookmarkBgView.layer.cornerRadius = GlobalCornerRadius.value
        emptyBookmarkBgView.clipsToBounds = true
        emptyBookmarkBgView.backgroundColor = .darkGray
        
        //gradient bg
        emptyBookmarkGradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyBookmarkGradientBg.animationDuration = 2.5
        emptyBookmarkGradientBg.setColors([UIColor(hexString: "#C06C84"), UIColor(hexString: "#6C5B7B"), UIColor(hexString: "#355C7D")])
        emptyBookmarkShadowView.layer.shadowColor = UIColor(hexString: "#6C5B7B").cgColor
        
        emptyBookmarkGradientBg.startAnimation()
        
        emptyBookmarkBgView.insertSubview(emptyBookmarkGradientBg, at: 0)
        emptyBookmarkShadowView.addSubview(emptyBookmarkBgView)
        
        let emptyBookmarkImgView = UIImageView()
        emptyBookmarkImgView.image = UIImage(named: "icon_confused")
        emptyBookmarkBgView.addSubview(emptyBookmarkImgView)
        emptyBookmarkImgView.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.size.equalTo(64)
        }
        
        let emptyBookmarkDesc = UILabel()
        emptyBookmarkDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        emptyBookmarkDesc.text = "Bookmark your instersted events now!"
        emptyBookmarkDesc.textColor = .white
        emptyBookmarkDesc.numberOfLines = 2
        emptyBookmarkBgView.addSubview(emptyBookmarkDesc)
        emptyBookmarkDesc.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalTo(25)
            make.width.equalTo(230)
        }
        
        let emptyBookmarkTitle = UILabel()
        emptyBookmarkTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        emptyBookmarkTitle.text = "What? Empty???"
        emptyBookmarkTitle.textColor = .white
        emptyBookmarkBgView.addSubview(emptyBookmarkTitle)
        emptyBookmarkTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(emptyBookmarkDesc.snp.top).offset(-5)
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
        //            make.bottom.equalTo(emptyBookmarkBgView.snp.bottom).offset(-25)
        //            make.right.equalTo(emptyBookmarkBgView.snp.right).offset(-25)
        //            make.width.equalTo(120)
        //            make.height.equalTo(28)
        //        }
        //
        //        learnMoreBtn.addTarget(self, action: #selector(showLoginVC), for: .touchUpInside)
        addSubview(emptyBookmarkShadowView)
        
    }
}

//MARK: - API Calls
extension BookmarkedSection {
    func getBookmarkedEvents(completion: (() -> Void)? = nil) {
        UserService.getBookmarkedEvents().done { response in
            if response.list.isEmpty { self.setupEmptyBookmarkView() }
            self.bookmarkedEvents = response.list.reversed()
            for _ in 0 ..< self.bookmarkedEvents.count {
                self.boolArr.append(Int.random(in: 0 ... 1))
            }
            for event in response.list {
                if let eventID = event.targetEvent!.id {
                    if !self.bookmarkedEventIDArray.contains(eventID) {
                        self.bookmarkedEventIDArray.append(eventID)
                    }
                }
            }
            
            print("Bookmarked events list count: \(response.list.count)")
            print("Initial bookmarkedEventIDArray: \(self.bookmarkedEventIDArray)")
            
            self.bookmarksCollectionView.reloadData()
            }.ensure {
                self.bookmarksCollectionView.isUserInteractionEnabled = true
                if self.reloadIndicator.alpha != 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.reloadIndicator.alpha = 0
                    }
                }
                
                NotificationCenter.default.post(name: .eventListEndRefreshing, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let completion = completion { completion() }
            }.catch { error in }
        
    }
}

//MARK: - UICollectionView delegate
extension BookmarkedSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = UserService.current.isLoggedIn() && !bookmarkedEvents.isEmpty ? bookmarkedEvents.count : 3
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookmarksCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedSectionCell.reuseIdentifier, for: indexPath) as! BookmarkedSectionCell
        if !bookmarkedEvents.isEmpty {
            if let event = bookmarkedEvents[indexPath.row].targetEvent {
                for view in cell.skeletonViews { //hide all skeleton views
                    view.hideSkeleton()
                }
                
                cell.delegate = self
                cell.myIndexPath = indexPath
                cell.eventTitle.text = event.title
                
                if let eventDate = event.dateTime?.toDate(), let currentDate = Date().toISO().toDate() {
                    let difference = DateTimeHelper.getEventInterval(from: currentDate, to: eventDate)
                    cell.dateLabel.text = difference
                }
                
                cell.performerLabel.text = event.organizerProfile?.name
                cell.bookmarkBtn.backgroundColor = .mintGreen()
                
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
                cell.verifiedIcon.alpha = self.bookmarkedEvents[indexPath.row].targetEvent?.organizerProfile?.verified ?? true ? 1 : 0
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: BookmarkedSectionCell.width, height: BookmarkedSectionCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let eventID = bookmarkedEvents[indexPath.row].targetEvent?.id {
            delegate?.bookmarkedCellTapped(eventID: eventID)
        }
    }
}

//MARK: - Bookmarked cell delegate
extension BookmarkedSection: BookmarkedSectionCellDelegate {
    func bookmarkBtnTapped(cell: BookmarkedSectionCell, tappedIndex: IndexPath) {
        if let eventID = bookmarkedEvents[tappedIndex.row].targetEvent?.id {
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
                        self.bookmarkedEventIDArray.append(eventID) //the cell is now hold by this array and will not have cell reuse issues
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
                        HapticFeedback.createNotificationFeedback(style: .success)
                    }.catch { error in }
                
            } else { //remove bookmark
                HapticFeedback.createImpact(style: .light)
                cell.bookmarkBtn.isUserInteractionEnabled = false
                
                //animate button state
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarkBtnIndicator.alpha = 1
                }
                
                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.bookmarkBtn.setImage(nil, for: .normal)
                }, completion: nil)
                
                //remove bookmark action
                EventService.removeBookmark(eventID: eventID).done { response in
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
                        
                        if let eventID = self.bookmarkedEvents[tappedIndex.row].targetEvent?.id {
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["remove_id": eventID])
                            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["remove_id": eventID])
                            NotificationCenter.default.post(name: .refreshFeaturedSectionCell, object: nil, userInfo: ["remove_id": eventID])
                            
                            self.bookmarkedEventIDArray.remove(object: eventID)
                            print("bookmarkedEventIDArray : \(self.bookmarkedEventIDArray)")
                        }
                        
                        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil) //reload collection view in this view
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        HapticFeedback.createNotificationFeedback(style: .success)
                    }.catch { error in }
            }
            
        } else {
            print("Can't get bookamrk section event id")
        }
        
    }
}
